import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../cl_theme.dart';
import '../../buttons/cl_icon_button.widget.dart';
import '../../buttons/cl_soft_button.widget.dart';
import 'cl_ai_chat_composer.widget.dart';
import 'cl_ai_chat_message.model.dart';
import 'cl_ai_message_bubble.widget.dart';

/// Chat AI **senza logica di agente**: riceve i messaggi e restituisce le azioni con callback.
/// Chi la usa (es. l'assistente di Skillera Ops collegato al servizio AI) tiene lo stato.
///
/// - lista dei [messages] con entrata animata (solo i messaggi nuovi: quelli presenti al primo
///   build non si animano);
/// - riga «sta pensando» con [isThinking], [thinkingLabel] e i passi facoltativi [thinkingSteps]
///   (l'ultimo è quello in corso);
/// - stato vuoto con saluto ([emptyTitle], [emptySubtitle]) e [suggestions] cliccabili, oppure
///   [emptyState] al suo posto;
/// - composer ([CLAiChatComposer]) con Invio invia / Maiusc+Invio a capo / ⌘Invio, e «Stop» se
///   c'è [onStop] mentre [isThinking];
/// - scroll automatico in fondo all'arrivo di contenuto, **solo se** l'utente è già in fondo (o ha
///   appena inviato): se ha scrollato su resta dov'è e compare il pulsante «Vai in fondo».
///
/// Con [showComposer] `false` resta solo la lista (es. dentro un guscio che ha il suo composer);
/// [padding] serve a far scorrere i messaggi sotto barre sovrapposte.
class CLAiChatView extends StatefulWidget {
  const CLAiChatView({
    super.key,
    required this.messages,
    this.onSend,
    this.onStop,
    this.isThinking = false,
    this.thinkingLabel,
    this.thinkingSteps = const [],
    this.suggestions = const [],
    this.onSuggestionTap,
    this.emptyTitle = 'Ciao',
    this.emptySubtitle = 'Come posso aiutarti oggi?',
    this.emptyState,
    this.showComposer = true,
    this.composerEnabled = true,
    this.composerHint = 'Scrivi un messaggio...',
    this.composerController,
    this.composerFocusNode,
    this.composerFooter,
    this.enterToSend = true,
    this.assistantAvatar,
    this.onLinkTap,
    this.padding,
    this.maxContentWidth,
    this.scrollController,
  });

  final List<CLAiChatMessage> messages;

  /// Testo scritto nel composer (o di un suggerimento, se manca [onSuggestionTap]).
  final ValueChanged<String>? onSend;
  final VoidCallback? onStop;
  final bool isThinking;

  /// Di serie «Sto pensando…».
  final String? thinkingLabel;
  final List<String> thinkingSteps;

  final List<CLAiChatSuggestion> suggestions;

  /// Tap su un suggerimento. Senza, il suggerimento è inviato con [onSend].
  final ValueChanged<CLAiChatSuggestion>? onSuggestionTap;
  final String emptyTitle;
  final String? emptySubtitle;

  /// Sostituisce lo stato vuoto di serie.
  final Widget? emptyState;

  final bool showComposer;
  final bool composerEnabled;
  final String composerHint;
  final TextEditingController? composerController;
  final FocusNode? composerFocusNode;
  final Widget? composerFooter;
  final bool enterToSend;

  final Widget? assistantAvatar;
  final ValueChanged<String>? onLinkTap;

  /// Margini interni della lista. Di serie `gapLg` sui quattro lati.
  final EdgeInsets? padding;

  /// Larghezza massima della colonna dei messaggi (centrata), per pannelli larghi.
  final double? maxContentWidth;
  final ScrollController? scrollController;

  @override
  State<CLAiChatView> createState() => _CLAiChatViewState();
}

class _CLAiChatViewState extends State<CLAiChatView> {
  ScrollController? _ownScroll;
  ScrollController get _scroll => widget.scrollController ?? (_ownScroll ??= ScrollController());

  /// Id già mostrati: non si animano di nuovo (né al primo build, né tornando visibili).
  final Set<String> _known = {};

  /// L'utente è in fondo alla lista: il contenuto nuovo lo segue.
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    _known.addAll(widget.messages.map((m) => m.id));
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom(animate: false));
  }

  @override
  void didUpdateWidget(CLAiChatView old) {
    super.didUpdateWidget(old);
    final grew = widget.messages.length != old.messages.length;
    final lastChanged = widget.messages.isNotEmpty &&
        (old.messages.isEmpty ||
            old.messages.last.id != widget.messages.last.id ||
            old.messages.last.text != widget.messages.last.text ||
            old.messages.last.status != widget.messages.last.status);
    final thinkingChanged =
        old.isThinking != widget.isThinking || old.thinkingSteps.length != widget.thinkingSteps.length;
    if (!grew && !lastChanged && !thinkingChanged) return;

    // Un messaggio nuovo dell'utente (ha appena inviato) riporta sempre in fondo.
    final userJustSent =
        grew && widget.messages.isNotEmpty && widget.messages.last.isUser && !_known.contains(widget.messages.last.id);
    if (_atBottom || userJustSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
    } else {
      setState(() {}); // mostra «Vai in fondo»
    }
  }

  @override
  void dispose() {
    _ownScroll?.dispose();
    super.dispose();
  }

  void _toBottom({bool animate = true}) {
    if (!mounted || !_scroll.hasClients) return;
    final theme = CLTheme.of(context);
    // La lista è pigra: maxScrollExtent è una stima finché gli ultimi elementi non sono
    // impaginati. Dopo l'animazione si rifinisce con qualche salto fino al fondo vero.
    void settle([int left = 4]) {
      if (!mounted || !_scroll.hasClients || left == 0) return;
      final p = _scroll.position;
      if (p.pixels < p.maxScrollExtent) {
        _scroll.jumpTo(p.maxScrollExtent);
        WidgetsBinding.instance.addPostFrameCallback((_) => settle(left - 1));
      }
    }

    if (animate && !MediaQuery.of(context).disableAnimations) {
      _scroll
          .animateTo(_scroll.position.maxScrollExtent, duration: theme.durationBase, curve: theme.easingStandard)
          .then((_) => settle());
    } else {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      WidgetsBinding.instance.addPostFrameCallback((_) => settle());
    }
    if (!_atBottom) setState(() => _atBottom = true);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final atBottom = n.metrics.extentAfter <= CLTheme.of(context).gap4Xl;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final messages = widget.messages;
    final padding = widget.padding ?? EdgeInsets.all(theme.gapLg);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget constrain(Widget child) => widget.maxContentWidth == null
        ? child
        : Center(
            child: ConstrainedBox(constraints: BoxConstraints(maxWidth: widget.maxContentWidth!), child: child),
          );

    final Widget body;
    if (messages.isEmpty && !widget.isThinking) {
      final gradient = LinearGradient(colors: [theme.primary, theme.accentPurple]);
      body = widget.emptyState ??
          LayoutBuilder(
            builder: (context, constraints) {
              final pad = padding + EdgeInsets.all(theme.gapSm);
              return SingleChildScrollView(
                padding: pad,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: (constraints.maxHeight - pad.vertical).clamp(0, double.infinity)),
                  child: constrain(Column(
                    // Ancorato in basso: saluto subito sopra i suggerimenti, vicino al composer.
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => gradient.createShader(Offset.zero & b.size),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          widget.emptyTitle,
                          style: theme.heading2.copyWith(color: theme.primaryForeground, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (widget.emptySubtitle != null) ...[
                        SizedBox(height: theme.gapXs),
                        Text(
                          widget.emptySubtitle!,
                          style: theme.heading2.copyWith(color: theme.secondaryText, fontWeight: FontWeight.w700),
                        ),
                      ],
                      if (widget.suggestions.isNotEmpty) ...[
                        SizedBox(height: theme.gapLg),
                        Wrap(
                          spacing: theme.gapSm,
                          runSpacing: theme.gapSm,
                          children: [
                            for (final s in widget.suggestions)
                              KeyedSubtree(
                                key: ValueKey('cl-ai-suggestion-${s.label}'),
                                child: CLSoftButton.primary(
                                  text: s.label,
                                  icon: s.icon,
                                  context: context,
                                  borderRadius: theme.radiusPill,
                                  onTap: () => widget.onSuggestionTap != null
                                      ? widget.onSuggestionTap!(s)
                                      : widget.onSend?.call(s.text),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  )),
                ),
              );
            },
          );
    } else {
      final count = messages.length + (widget.isThinking ? 1 : 0);
      final avatarSize = theme.iconSizeLarge + theme.gapXs;
      body = Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView.builder(
              controller: _scroll,
              padding: padding,
              itemCount: count,
              itemBuilder: (context, index) {
                // ── riga «sta pensando» ─────────────────────────────────────
                if (index == messages.length) {
                  final steps = widget.thinkingSteps;
                  return constrain(Padding(
                    key: const ValueKey('cl-ai-thinking'),
                    padding: EdgeInsets.only(bottom: theme.gapMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.assistantAvatar ??
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: theme.opacitySoft),
                                borderRadius: BorderRadius.circular(theme.radiusControl),
                              ),
                              child: Icon(LucideIcons.sparkles, size: theme.iconSizeCompact, color: theme.primary),
                            ),
                        SizedBox(width: theme.gapSm),
                        Flexible(
                          child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm + theme.gapXs / 2),
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              borderRadius: BorderRadius.circular(theme.radiusSurface),
                              border: Border.all(color: theme.borderColor.withValues(alpha: theme.opacityStrong)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: theme.iconSizeCompact - theme.gapXs,
                                      height: theme.iconSizeCompact - theme.gapXs,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                                    ),
                                    SizedBox(width: theme.gapSm),
                                    Flexible(
                                      child: Text(
                                        widget.thinkingLabel ?? 'Sto pensando…',
                                        style: theme.bodyLabel.copyWith(color: theme.secondaryText),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var i = 0; i < steps.length; i++)
                                  Padding(
                                    padding: EdgeInsets.only(top: theme.gapXs),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          i == steps.length - 1 ? LucideIcons.arrowRight : LucideIcons.check,
                                          size: theme.iconSizeCompact - theme.gapXs,
                                          color: i == steps.length - 1 ? theme.primary : theme.success,
                                        ),
                                        SizedBox(width: theme.gapSm),
                                        Flexible(
                                          child: Text(
                                            steps[i],
                                            style: theme.smallLabel.copyWith(
                                              color: i == steps.length - 1 ? theme.primaryText : theme.secondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
                }

                final msg = messages[index];
                final isNew = !_known.contains(msg.id);
                _known.add(msg.id);
                final bubble = Padding(
                  padding: EdgeInsets.only(bottom: theme.gapMd),
                  child: CLAiMessageBubble(
                    message: msg,
                    avatar: widget.assistantAvatar,
                    onLinkTap: widget.onLinkTap,
                  ),
                );
                return constrain(KeyedSubtree(
                  key: ValueKey('cl-ai-row-${msg.id}'),
                  // Sempre lo stesso widget: un messaggio già visto parte da 1 (nessuna animazione),
                  // uno nuovo da 0; un rebuild a metà non interrompe l'entrata.
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: isNew ? 0 : 1, end: 1),
                    duration: reduceMotion ? Duration.zero : theme.durationSlow,
                    curve: theme.easingStandard,
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.translate(offset: Offset(0, (1 - t) * theme.gapMd), child: child),
                    ),
                    child: bubble,
                  ),
                ));
              },
            ),
          ),
          if (!_atBottom)
            Positioned(
              right: theme.gapLg,
              bottom: padding.bottom + theme.gapSm,
              child: CLIconButton(
                key: const ValueKey('cl-ai-scroll-bottom'),
                iconData: LucideIcons.arrowDown,
                tooltip: 'Vai in fondo',
                backgroundColor: theme.secondaryBackground,
                iconColor: theme.primaryText,
                boxShadow: theme.cardShadowSoft,
                borderRadius: theme.radiusPill,
                onTap: _toBottom,
              ),
            ),
        ],
      );
    }

    if (!widget.showComposer) return body;
    return Column(
      children: [
        Expanded(child: body),
        constrain(CLAiChatComposer(
          onSend: widget.onSend,
          onStop: widget.onStop,
          busy: widget.isThinking,
          enabled: widget.composerEnabled,
          hintText: widget.composerHint,
          controller: widget.composerController,
          focusNode: widget.composerFocusNode,
          enterToSend: widget.enterToSend,
          footer: widget.composerFooter,
        )),
      ],
    );
  }
}

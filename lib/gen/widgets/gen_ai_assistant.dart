import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadDecoration, ShadBorder;

import '../theme/gen_tokens.dart';
import '../theme/gen_icon.dart';
import '../primitives/gen_primitives.dart';
import '../primitives/gen_overlays.dart';

/// Ruolo di un messaggio chat.
enum GenChatRole { user, assistant }

/// Messaggio della chat AI (presentazionale).
@immutable
class GenChatMessage {
  const GenChatMessage({required this.role, required this.content});

  final GenChatRole role;
  final String content;

  bool get isUser => role == GenChatRole.user;
}

/// Chip suggerimento mostrata nell'empty state.
@immutable
class GenChatSuggestion {
  const GenChatSuggestion({required this.icon, required this.label, required this.message});

  final IconData icon;
  final String label;
  final String message;
}

/// Voce di cronologia conversazioni (per il dialog "Conversazioni").
@immutable
class GenChatConversation {
  const GenChatConversation({required this.id, required this.title, this.subtitle});

  final String id;
  final String title;
  final String? subtitle;
}

/// Assistente AI — pannello chat SOLO UI (nessuna logica LLM). Config-driven:
/// riceve [messages] + callback [onSend]; l'app possiede stato/inferenza. Pensato
/// per lo slot `trailing` di GenAdaptiveShell (bolla accanto al body): header
/// (titolo + chiudi) · lista messaggi (bolle user/assistant, typing) · input
/// (multiline + send/stop) · empty state (saluto + suggerimenti).
class GenAiAssistant extends StatefulWidget {
  const GenAiAssistant({
    super.key,
    required this.messages,
    required this.onSend,
    this.isProcessing = false,
    this.progressText,
    this.onStop,
    this.onAttach,
    this.onPrivacy,
    this.onClose,
    this.title = 'Assistente',
    this.greetingName,
    this.suggestions = const [],
    this.onSuggestion,
    this.hintText = 'Scrivi un messaggio…',
    this.onNewChat,
    this.conversations = const [],
    this.onOpenConversation,
    this.onDeleteConversation,
    this.conversationTitle,
  });

  /// Nome della conversazione corrente. Se null → primo messaggio utente,
  /// altrimenti "Nuova conversazione".
  final String? conversationTitle;

  final List<GenChatMessage> messages;
  final ValueChanged<String> onSend;
  final bool isProcessing;
  final String? progressText;
  final VoidCallback? onStop;

  /// Tap sul pulsante allegati del footer. Se null → pulsante disabilitato.
  final VoidCallback? onAttach;

  /// Tap sul link "Informativa completa" nella riga privacy del footer.
  final VoidCallback? onPrivacy;
  final VoidCallback? onClose;
  final String title;
  final String? greetingName;
  final List<GenChatSuggestion> suggestions;

  /// Tap su un suggerimento; se null → `onSend(suggestion.message)`.
  final ValueChanged<GenChatSuggestion>? onSuggestion;
  final String hintText;

  /// Avvia una nuova conversazione. Se non-null, l'header mostra il pulsante
  /// cronologia (→ dialog "Conversazioni" con "Nuova" + storico).
  final VoidCallback? onNewChat;
  final List<GenChatConversation> conversations;
  final ValueChanged<String>? onOpenConversation;
  final ValueChanged<String>? onDeleteConversation;

  @override
  State<GenAiAssistant> createState() => _GenAiAssistantState();
}

class _GenAiAssistantState extends State<GenAiAssistant> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _scroll = ScrollController();

  /// Tap sul link "Informativa completa" (inline nel disclaimer privacy).
  final _privacyTap = TapGestureRecognizer();

  /// Sigma blur delle barre frosted (header/footer). Uguale allo shell.
  static const double _frostSigma = 18.0;

  /// Altezze misurate di header/footer frosted: la lista/empty riceve un inset
  /// top/bottom pari a queste così il contenuto scorre SOTTO il vetro.
  double _headerH = 0;
  double _footerH = 0;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    // Rebuild su focus → il glow ring compare/scompare.
    _inputFocus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant GenAiAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length || widget.isProcessing != oldWidget.isProcessing) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _canSend => _input.text.trim().isNotEmpty && !widget.isProcessing;

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || widget.isProcessing) return;
    widget.onSend(text);
    _input.clear();
    _inputFocus.requestFocus();
  }

  void _tapSuggestion(GenChatSuggestion s) {
    if (widget.onSuggestion != null) {
      widget.onSuggestion!(s);
    } else {
      widget.onSend(s.message);
    }
  }

  /// Dialog "Conversazioni": bottone Nuova + storico (apri/elimina).
  void _showHistory(BuildContext context) {
    showGenDialog<void>(
      context: context,
      opaque: false,
      builder: (dctx) {
        final t = GenTokens.of(dctx);
        return GenDialog(
          title: Text('Conversazioni', style: t.heading4),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in widget.conversations)
                _ConvTile(
                  conversation: c,
                  onOpen: () {
                    Navigator.of(dctx).pop();
                    widget.onOpenConversation?.call(c.id);
                  },
                  onDelete: widget.onDeleteConversation == null ? null : () => widget.onDeleteConversation!(c.id),
                ),
              if (widget.conversations.isNotEmpty) SizedBox(height: t.gapMd),
              // Nuova conversazione in fondo alla lista.
              GenButton(
                onPressed: () {
                  Navigator.of(dctx).pop();
                  widget.onNewChat?.call();
                },
                leading: const GenIcon(LucideIcons.plus),
                child: const Text('Nuova conversazione'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final empty = widget.messages.isEmpty;
    // Stack: contenuto full-height che scorre SOTTO le barre frosted di
    // header (titolo/chiudi) e footer (input). Inset top/bottom = altezze
    // misurate → primo/ultimo item non restano coperti in modo permanente.
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: _headerH, bottom: _footerH),
            child: empty ? _emptyState(t) : _messages(t),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _MeasureSize(
            onChange: (s) {
              if (s.height != _headerH) setState(() => _headerH = s.height);
            },
            child: _frostedBar(t, child: _header(t)),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _MeasureSize(
            onChange: (s) {
              if (s.height != _footerH) setState(() => _footerH = s.height);
            },
            child: _frostedBar(t, child: _inputBar(t)),
          ),
        ),
      ],
    );
  }

  /// Barra frosted: blur + superficie translucida (nessun hairline).
  Widget _frostedBar(GenTokens t, {required Widget child}) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _frostSigma, sigmaY: _frostSigma),
      child: DecoratedBox(
        decoration: BoxDecoration(color: t.secondaryBackground.withValues(alpha: 0.82)),
        child: child,
      ),
    ),
  );

  /// Titolo conversazione: [conversationTitle] esplicito, altrimenti primo
  /// messaggio utente, altrimenti "Nuova conversazione". Ellipsis a livello UI.
  String get _convTitle {
    if (widget.conversationTitle != null && widget.conversationTitle!.trim().isNotEmpty) {
      return widget.conversationTitle!;
    }
    for (final m in widget.messages) {
      if (m.isUser) return m.content;
    }
    return 'Nuova conversazione';
  }

  Widget _header(GenTokens t) => Padding(
    padding: EdgeInsets.all(t.gapLg),
    child: Row(
      children: [
        // Titolo = GenButton.ghost (title + chevron) che apre il dialog
        // "Conversazioni". Fallback Text se non c'è gestione conversazioni.
        // Expanded: l'area titolo occupa lo spazio → il close resta a end
        // (non si muove durante il typing). Align: il button hugga a sinistra,
        // l'ellipsis scatta solo se il testo supera l'area.
        Expanded(
          child: widget.onNewChat == null
              ? Text(
                  widget.title,
                  style: t.bodyText.copyWith(color: t.primaryText),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: _ChatTitleButton(title: _convTitle, onTap: () => _showHistory(context)),
                ),
        ),
        if (widget.isProcessing)
          Padding(
            padding: EdgeInsets.only(right: t.gapSm),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: t.secondaryText),
            ),
          ),
        if (widget.onClose != null)
          GenIconButton.ghost(
            onPressed: widget.onClose,
            icon: GenIcon(LucideIcons.x400, size: t.iconSizeDefault),
          ),
      ],
    ),
  );

  Widget _emptyState(GenTokens t) => LayoutBuilder(
    builder: (context, c) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: c.maxHeight),
        child: Padding(
          padding: EdgeInsets.all(t.gapLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saluto con gradient brand (ShaderMask sul testo bianco).
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (r) => LinearGradient(colors: [t.primary, const Color(0xFF4F46E5)]).createShader(r),
                child: Text(
                  widget.greetingName != null ? 'Ciao ${widget.greetingName}' : 'Ciao',
                  style: t.heading2.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: t.gapXs),
              Text('Come posso aiutarti oggi?', style: t.heading4.copyWith(color: t.secondaryText)),
              SizedBox(height: t.gapLg),
              Wrap(
                spacing: t.gapSm,
                runSpacing: t.gapSm,
                children: [
                  // Hint pill = GenBadge (no icona), padding maggiore per look pill.
                  for (final s in widget.suggestions)
                    GenBadge.secondary(
                      onPressed: () => _tapSuggestion(s),
                      padding: EdgeInsets.symmetric(horizontal: t.gapMd, vertical: t.gapSm),
                      child: Text(s.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _messages(GenTokens t) {
    final showTyping = widget.isProcessing;
    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.symmetric(horizontal: t.gapLg, vertical: t.gapMd),
      itemCount: widget.messages.length + (showTyping ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == widget.messages.length) return _typing(t);
        return _bubble(t, widget.messages[i]);
      },
    );
  }

  Widget _bubble(GenTokens t, GenChatMessage m) {
    final radius = Radius.circular(t.radiusCard);
    final tail = const Radius.circular(4);
    return Padding(
      padding: EdgeInsets.only(bottom: t.gapLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: t.gapMd, vertical: t.gapSm),
              decoration: BoxDecoration(
                color: m.isUser ? t.primary.withValues(alpha: 0.12) : t.primaryBackground,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: m.isUser ? radius : tail,
                  bottomRight: m.isUser ? tail : radius,
                ),
              ),
              child: SelectableText(m.content, style: t.bodyText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typing(GenTokens t) => Padding(
    padding: EdgeInsets.only(bottom: t.gapLg),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: t.gapMd, vertical: t.gapSm),
          decoration: BoxDecoration(
            color: t.primaryBackground,
            borderRadius: BorderRadius.circular(t.radiusCard),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: t.secondaryText)),
              SizedBox(width: t.gapSm),
              Text(widget.progressText ?? 'Sto elaborando…', style: t.smallText.copyWith(color: t.secondaryText)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _inputBar(GenTokens t) => Padding(
    padding: EdgeInsets.all(t.gapLg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GlowRing(
          radius: t.radiusControl,
          active: _inputFocus.hasFocus,
          child: GenTextarea(
            controller: _input,
            focusNode: _inputFocus,
            placeholder: Text(widget.hintText),
            minHeight: t.buttonHeightDefault * 1.8,
            maxHeight: 160,
            decoration: const ShadDecoration(border: ShadBorder.none, focusedBorder: ShadBorder.none),
          ),
        ),
        SizedBox(height: t.gapSm),
        // Azioni sotto la textarea: allegati (outline) a sinistra · invio/stop a destra.
        Row(
          children: [
            GenIconButton.outline(
              onPressed: widget.onAttach,
              icon: const GenIcon(LucideIcons.paperclip),
            ),
            const Spacer(),
            widget.isProcessing && widget.onStop != null
                ? GenIconButton.destructive(onPressed: widget.onStop, icon: const GenIcon(LucideIcons.square))
                : GenIconButton(onPressed: _canSend ? _send : null, icon: const GenIcon(LucideIcons.arrowUp)),
          ],
        ),
        SizedBox(height: t.gapLg),
        // Disclaimer privacy AI + link inline (stesso paragrafo, colore primary).
        Text.rich(
          TextSpan(
            style: t.smallText.copyWith(color: t.secondaryText),
            children: [
              const TextSpan(text: 'L\'AI può commettere errori. Non condividere dati sensibili. '),
              TextSpan(
                text: 'Informativa completa',
                style: TextStyle(color: t.primary),
                recognizer: _privacyTap..onTap = widget.onPrivacy,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Riga cronologia conversazione: icona + titolo/sottotitolo tappabile + elimina.
/// Composta da elementi Gen (GenIcon/GenIconButton/token) + Row/Container hover
/// (niente GenButton esterno: con trailing annidato + Expanded dava "no size").
class _ConvTile extends StatefulWidget {
  const _ConvTile({required this.conversation, required this.onOpen, this.onDelete});

  final GenChatConversation conversation;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  State<_ConvTile> createState() => _ConvTileState();
}

class _ConvTileState extends State<_ConvTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onOpen,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: t.gapSm, vertical: t.gapSm),
          decoration: BoxDecoration(
            color: _hovered ? t.accent : null,
            borderRadius: BorderRadius.circular(t.radiusControl),
          ),
          child: Row(
            children: [
              GenIcon(LucideIcons.messageSquare, size: t.iconSizeCompact, color: t.secondaryText),
              SizedBox(width: t.gapSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.conversation.title,
                      style: t.bodyLabel.copyWith(color: t.primaryText),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (widget.conversation.subtitle != null)
                      Text(
                        widget.conversation.subtitle!,
                        style: t.smallText.copyWith(color: t.secondaryText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              if (widget.onDelete != null) ...[
                SizedBox(width: t.gapSm),
                GenIconButton.ghost(
                  onPressed: widget.onDelete,
                  iconSize: t.iconSizeCompact,
                  padding: EdgeInsets.all(t.gapXs),
                  icon: GenIcon(LucideIcons.trash2, color: t.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordo animato: anello a gradiente conico (SweepGradient) che RUOTA con glow,
/// attorno al [child] (l'input). L'interno è opaco (secondaryBackground) → il
/// gradiente resta visibile solo come ring di larghezza [width].
class _GlowRing extends StatefulWidget {
  const _GlowRing({required this.child, required this.radius, this.active = false});

  final Widget child;
  final double radius;

  /// Solo quando `true` (input in focus) l'anello ruota col gradiente+glow;
  /// altrimenti bordo statico `borderColor`.
  final bool active;

  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const double _w = 1.5;

  @override
  void initState() {
    super.initState();
    // Init NON lazy: con `late final = ...` un dispose senza mai aver letto
    // `_ctrl` (input mai in focus) creerebbe il controller DENTRO dispose →
    // createTicker su element disattivato → crash.
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant _GlowRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    const accent = Color(0xFF4F46E5);
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius - _w),
      child: ColoredBox(color: t.secondaryBackground, child: widget.child),
    );
    // Struttura COSTANTE (AnimatedBuilder>Container>inner) in ogni stato: se il
    // wrapper cambia forma tra focus/non-focus, `inner` (con la textarea) viene
    // rimontato e perde il focus → serviva un secondo tap per scrivere. Toggle
    // SOLO la decoration in base a `active`.
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final active = widget.active;
        return Container(
          padding: const EdgeInsets.all(_w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: active ? null : t.borderColor,
            gradient: active
                ? SweepGradient(
                    colors: [t.primary, accent, t.primary, accent, t.primary],
                    transform: GradientRotation(_ctrl.value * 2 * math.pi),
                  )
                : null,
            boxShadow: active
                ? [
                    BoxShadow(color: t.primary.withValues(alpha: 0.28), blurRadius: 14, spreadRadius: -2),
                    BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 14, spreadRadius: -2),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: inner,
    );
  }
}

/// Titolo conversazione come bottone ghost (custom: GenButton non gestisce
/// ellipsis+flex del child). Hover pill + chevron; apre il dialog conversazioni.
class _ChatTitleButton extends StatefulWidget {
  const _ChatTitleButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  State<_ChatTitleButton> createState() => _ChatTitleButtonState();
}

class _ChatTitleButtonState extends State<_ChatTitleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: t.buttonHeightDefault,
          padding: EdgeInsets.symmetric(horizontal: t.gapMd),
          decoration: BoxDecoration(
            color: _hovered ? t.secondaryText.withValues(alpha: t.opacitySoft) : null,
            borderRadius: BorderRadius.circular(t.radiusControl),
          ),
          // min: il pill hugga il contenuto (titolo+chevron); il Flexible sul
          // testo dà l'ellipsis quando lo spazio disponibile finisce.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: _TypingText(
                  text: widget.title,
                  style: t.bodyText.copyWith(color: t.primaryText, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(width: t.gapSm),
              GenIcon(LucideIcons.chevronDown, size: t.iconSizeCompact, color: t.primaryText),
            ],
          ),
        ),
      ),
    );
  }
}

/// Testo con animazione di typing: quando [text] cambia, lo rivela carattere per
/// carattere. Ellipsis su singola riga.
class _TypingText extends StatefulWidget {
  const _TypingText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText> {
  late String _shown = widget.text;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant _TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _animate(widget.text);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _animate(String target) {
    _timer?.cancel();
    setState(() => _shown = '');
    var i = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 28), (tm) {
      i++;
      if (i >= target.length) {
        tm.cancel();
        if (mounted) setState(() => _shown = target);
      } else if (mounted) {
        setState(() => _shown = target.substring(0, i));
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      Text(_shown, style: widget.style, overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false);
}

/// Misura la [child] a fine frame e notifica [onChange] al cambio dimensione.
/// Usato per l'inset top/bottom del contenuto sotto le barre frosted.
class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _old;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = context.size;
      if (size != null && size != _old) {
        _old = size;
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}

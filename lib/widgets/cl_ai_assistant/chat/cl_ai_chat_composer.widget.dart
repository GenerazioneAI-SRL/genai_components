import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../cl_theme.dart';

/// Campo di scrittura della chat AI: area di testo con anello di focus a gradiente, pulsante
/// invia (o «Stop» mentre l'assistente lavora) e una nota facoltativa sotto.
///
/// Tastiera: **Invio** invia, **Maiusc+Invio** va a capo, **⌘Invio** / **Ctrl+Invio** inviano
/// sempre. Con [enterToSend] `false` Invio va a capo e inviano solo ⌘/Ctrl+Invio. Durante la
/// composizione IME (accenti, ideogrammi) Invio non invia.
///
/// Chiavi utili nei test: `cl-ai-composer-field`, `cl-ai-composer-send`, `cl-ai-composer-stop`.
class CLAiChatComposer extends StatefulWidget {
  const CLAiChatComposer({
    super.key,
    this.onSend,
    this.onStop,
    this.busy = false,
    this.enabled = true,
    this.hintText = 'Scrivi un messaggio...',
    this.controller,
    this.focusNode,
    this.minLines = 2,
    this.maxLines = 6,
    this.enterToSend = true,
    this.footer,
    this.autofocus = false,
  });

  /// Testo inviato (già senza spazi ai bordi). Il campo si svuota da solo. `null` = invio spento.
  final ValueChanged<String>? onSend;

  /// Con [busy] `true` il pulsante diventa «Stop» e chiama questo. Senza, durante [busy] l'invio
  /// è solo spento.
  final VoidCallback? onStop;

  /// L'assistente sta lavorando: niente invio (o «Stop» se c'è [onStop]).
  final bool busy;

  /// Se `false` non si scrive.
  final bool enabled;
  final String hintText;

  /// Controller esterno facoltativo (es. per precompilare). Se manca, ne crea uno suo.
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int minLines;
  final int maxLines;
  final bool enterToSend;

  /// Sotto il campo, es. l'informativa privacy.
  final Widget? footer;
  final bool autofocus;

  @override
  State<CLAiChatComposer> createState() => _CLAiChatComposerState();
}

class _CLAiChatComposerState extends State<CLAiChatComposer> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(CLAiChatComposer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _ownController)?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onChanged);
      _focus.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _focus.removeListener(_onChanged);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _canSend => widget.onSend != null && widget.enabled && !widget.busy && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    final text = _controller.text.trim();
    _controller.clear();
    widget.onSend!(text);
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter && event.logicalKey != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }
    if (_controller.value.composing.isValid) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    final withCommand = keys.isMetaPressed || keys.isControlPressed;
    if (!withCommand && (keys.isShiftPressed || !widget.enterToSend)) return KeyEventResult.ignored;
    _send();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final focused = _focus.hasFocus;
    final showStop = widget.busy && widget.onStop != null;
    final canSend = _canSend;
    final buttonSize = theme.buttonHeightDefault;

    return Padding(
      padding: EdgeInsets.all(theme.gapMd + theme.gapXs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Anello di 1px: gradiente primario → viola a fuoco, bordo neutro altrimenti.
          AnimatedContainer(
            duration: theme.durationFast,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: focused ? LinearGradient(colors: [theme.primary, theme.accentPurple]) : null,
              color: focused ? null : theme.borderColor,
              borderRadius: BorderRadius.circular(theme.radiusModal),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: theme.gapLg, vertical: theme.gapMd),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(theme.radiusModal - 1),
              ),
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onKeyEvent: _onKey,
                child: TextField(
                  key: const ValueKey('cl-ai-composer-field'),
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: theme.bodyText.copyWith(color: theme.primaryText),
                  cursorColor: theme.primary,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: theme.bodyText.copyWith(color: theme.secondaryText),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: theme.gapSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: showStop ? 'Stop' : 'Invia (Invio)',
                child: Material(
                  color: showStop
                      ? theme.secondaryText.withValues(alpha: theme.opacityStrong)
                      : (canSend ? theme.primary : theme.primary.withValues(alpha: theme.opacityDisabled)),
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: ValueKey(showStop ? 'cl-ai-composer-stop' : 'cl-ai-composer-send'),
                    customBorder: const CircleBorder(),
                    onTap: showStop ? widget.onStop : (canSend ? _send : null),
                    child: SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Icon(
                        showStop ? LucideIcons.square : LucideIcons.arrowUp,
                        color: theme.primaryForeground,
                        size: theme.iconSizeDefault - (showStop ? theme.gapXs : 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.footer != null) ...[
            SizedBox(height: theme.gapSm),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}

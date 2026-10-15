import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../cl_theme.dart';
import '../../../enums/message_role.enum.dart';
import '../../buttons/cl_link_button.widget.dart';
import 'cl_ai_chat_message.model.dart';
import 'src/ai_markdown_body.dart';

/// Un messaggio di [CLAiChatView], reso secondo ruolo e stato di [message]. Si può usare anche da
/// solo (es. l'anteprima di una risposta), ma di norma lo costruisce [CLAiChatView].
///
/// Chiavi utili nei test: `cl-ai-msg-<id>` (la bolla), `cl-ai-msg-<id>-cite-<n>` (riferimento nel
/// testo), `cl-ai-msg-<id>-source-<n>` (fonte nell'elenco sotto la bolla).
class CLAiMessageBubble extends StatefulWidget {
  const CLAiMessageBubble({
    super.key,
    required this.message,
    this.avatar,
    this.showAvatar = true,
    this.onLinkTap,
    this.retryLabel = 'Riprova',
    this.editLabel = 'Modifica',
  });

  final CLAiChatMessage message;

  /// Avatar dei messaggi dell'assistente. Di serie una scintilla su fondo primario tenue.
  final Widget? avatar;
  final bool showAvatar;

  /// Tap su un link markdown `[testo](url)`. Senza, il link è solo evidenziato.
  final ValueChanged<String>? onLinkTap;
  final String retryLabel;
  final String editLabel;

  @override
  State<CLAiMessageBubble> createState() => _CLAiMessageBubbleState();
}

class _CLAiMessageBubbleState extends State<CLAiMessageBubble> {
  TextEditingController? _edit;

  @override
  void dispose() {
    _edit?.dispose();
    super.dispose();
  }

  void _startEdit() => setState(() => _edit = TextEditingController(text: widget.message.text));

  void _endEdit({required bool save}) {
    final value = _edit!.text.trim();
    if (save && value.isNotEmpty && value != widget.message.text.trim()) {
      widget.message.onEdit?.call(value);
    }
    final old = _edit;
    setState(() => _edit = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final msg = widget.message;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyPrefix = 'cl-ai-msg-${msg.id}';
    final textStyle = theme.bodyText.copyWith(color: theme.primaryText);
    final isError = msg.status == CLAiChatStatus.error;
    final isBusy = msg.status == CLAiChatStatus.pending || msg.status == CLAiChatStatus.sending;
    final spinner = SizedBox(
      width: theme.iconSizeCompact - theme.gapXs,
      height: theme.iconSizeCompact - theme.gapXs,
      child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
    );

    // ── system: nota centrata ────────────────────────────────────────────────
    if (msg.role == MessageRole.system) {
      return Center(
        key: ValueKey(keyPrefix),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.gap2Xl),
          child: Text(msg.text, textAlign: TextAlign.center, style: theme.smallLabel),
        ),
      );
    }

    // ── tool: riga compatta ─────────────────────────────────────────────────
    if (msg.role == MessageRole.tool) {
      final color = isError ? theme.danger : theme.secondaryText;
      return Row(
        key: ValueKey(keyPrefix),
        children: [
          SizedBox(width: widget.showAvatar ? theme.iconSizeLarge + theme.gapXs + theme.gapSm : 0),
          isBusy ? spinner : Icon(LucideIcons.wrench, size: theme.iconSizeCompact - theme.gapXs, color: color),
          SizedBox(width: theme.gapSm),
          Flexible(
            child: Text(
              isError && msg.errorText != null ? '${msg.text} · ${msg.errorText}' : msg.text,
              style: theme.smallLabel.copyWith(color: color),
            ),
          ),
        ],
      );
    }

    final isUser = msg.isUser;
    final tail = Radius.circular(theme.radiusXs);
    final round = Radius.circular(theme.radiusSurface);
    final editing = _edit != null;

    final Widget content = editing
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: ValueKey('$keyPrefix-edit'),
                controller: _edit,
                autofocus: true,
                minLines: 1,
                maxLines: 8,
                style: textStyle,
                cursorColor: theme.primary,
                decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
              ),
              SizedBox(height: theme.gapSm),
              Wrap(
                spacing: theme.gapMd,
                children: [
                  CLLinkButton.secondary(
                    text: 'Annulla',
                    context: context,
                    isCompact: true,
                    onTap: () => _endEdit(save: false),
                  ),
                  KeyedSubtree(
                    key: ValueKey('$keyPrefix-edit-save'),
                    child: CLLinkButton.primary(
                      text: 'Salva',
                      context: context,
                      isCompact: true,
                      onTap: () => _endEdit(save: true),
                    ),
                  ),
                ],
              ),
            ],
          )
        : (msg.text.isEmpty && isBusy)
            ? Row(mainAxisSize: MainAxisSize.min, children: [spinner])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AiMarkdownBody(
                    text: msg.text,
                    style: textStyle,
                    markdown: msg.markdown,
                    citations: msg.citations,
                    keyPrefix: keyPrefix,
                    onLinkTap: widget.onLinkTap,
                  ),
                  if (msg.status == CLAiChatStatus.pending) ...[
                    SizedBox(height: theme.gapXs),
                    spinner,
                  ],
                ],
              );

    final bubble = AnimatedOpacity(
      opacity: msg.status == CLAiChatStatus.sending ? 1 - theme.opacityStrong : 1,
      duration: theme.durationFast,
      child: Container(
        key: ValueKey(keyPrefix),
        padding: EdgeInsets.symmetric(horizontal: theme.gapMd, vertical: theme.gapSm + theme.gapXs / 2),
        decoration: BoxDecoration(
          color: isUser
              ? theme.primary.withValues(alpha: isDark ? theme.opacityStrong : theme.opacitySoft)
              : (isDark ? theme.primaryBackground : theme.primaryBackground.withValues(alpha: 1 - theme.opacityStrong)),
          borderRadius: BorderRadius.only(
            topLeft: round,
            topRight: round,
            bottomLeft: isUser ? round : tail,
            bottomRight: isUser ? tail : round,
          ),
          border: Border.all(
            color: isError ? theme.danger : theme.borderColor.withValues(alpha: theme.opacityStrong),
          ),
        ),
        child: SelectionArea(child: content),
      ),
    );

    final status = switch (msg.status) {
      CLAiChatStatus.sending => Text('Invio…', style: theme.smallLabel),
      CLAiChatStatus.error => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: theme.gapSm,
          children: [
            Icon(LucideIcons.circleAlert, size: theme.iconSizeCompact - theme.gapXs, color: theme.danger),
            Text(
              msg.errorText ?? (isUser ? 'Messaggio non inviato' : 'Risposta non riuscita'),
              style: theme.smallLabel.copyWith(color: theme.danger),
            ),
            if (msg.onRetry != null)
              KeyedSubtree(
                key: ValueKey('$keyPrefix-retry'),
                child: CLLinkButton.primary(
                  text: widget.retryLabel,
                  icon: LucideIcons.rotateCcw,
                  context: context,
                  isCompact: true,
                  onTap: msg.onRetry!,
                ),
              ),
          ],
        ),
      _ => null,
    };
    final canEdit = isUser && msg.onEdit != null && !editing && msg.status != CLAiChatStatus.sending;

    final column = Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        bubble,
        if (status != null || canEdit) ...[
          SizedBox(height: theme.gapXs),
          Wrap(
            spacing: theme.gapMd,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (status != null) status,
              if (canEdit)
                KeyedSubtree(
                  key: ValueKey('$keyPrefix-edit-start'),
                  child: CLLinkButton.secondary(
                    text: widget.editLabel,
                    icon: LucideIcons.pencil,
                    context: context,
                    isCompact: true,
                    onTap: _startEdit,
                  ),
                ),
            ],
          ),
        ],
        if (msg.citations.isNotEmpty) ...[
          SizedBox(height: theme.gapSm),
          Wrap(
            spacing: theme.gapSm,
            runSpacing: theme.gapSm,
            children: [
              for (var i = 0; i < msg.citations.length; i++)
                MouseRegion(
                  cursor: msg.citations[i].onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
                  child: GestureDetector(
                    key: ValueKey('$keyPrefix-source-${i + 1}'),
                    onTap: msg.citations[i].onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: theme.gapXs),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        border: Border.all(color: theme.cardBorder),
                        borderRadius: BorderRadius.circular(theme.radiusChip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${i + 1}',
                            style: theme.smallLabel.copyWith(color: theme.primary, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: theme.gapSm),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.citations[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.smallText.copyWith(color: theme.primaryText),
                                ),
                                if (msg.citations[i].subtitle != null)
                                  Text(
                                    msg.citations[i].subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.smallLabel,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (msg.footer != null) ...[
          SizedBox(height: theme.gapSm),
          msg.footer!,
        ],
      ],
    );

    final avatarSize = theme.iconSizeLarge + theme.gapXs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isUser) SizedBox(width: theme.gap3Xl),
        if (!isUser && widget.showAvatar) ...[
          widget.avatar ??
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
        ],
        Flexible(child: column),
        if (!isUser) SizedBox(width: theme.gap3Xl),
      ],
    );
  }
}

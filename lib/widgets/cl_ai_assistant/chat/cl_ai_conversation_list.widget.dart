import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../cl_theme.dart';
import '../../buttons/cl_icon_button.widget.dart';
import '../../buttons/cl_soft_button.widget.dart';

/// Riga di [CLAiConversationList].
@immutable
class CLAiConversationItem {
  const CLAiConversationItem({required this.id, required this.title, this.updatedAt, this.subtitle});

  final String id;
  final String title;

  /// Data dell'ultimo messaggio: resa come «oggi», «ieri», «3g fa», «12/09».
  final DateTime? updatedAt;

  /// Seconda riga al posto della data (es. l'anteprima dell'ultimo messaggio).
  final String? subtitle;
}

/// Storico delle conversazioni AI: titolo, data, riga selezionata, «Nuova», «Archivia» ed
/// «Elimina». Solo dati e callback: caricamento e persistenza li fa chi la usa.
///
/// L'intestazione (titolo + «Nuova») compare con [title] o [onNew]. Le azioni di riga compaiono
/// solo se c'è la loro callback. Chiavi utili nei test: `cl-ai-conv-<id>`,
/// `cl-ai-conv-<id>-archive`, `cl-ai-conv-<id>-delete`, `cl-ai-conv-new`.
class CLAiConversationList extends StatelessWidget {
  const CLAiConversationList({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelect,
    this.onNew,
    this.onArchive,
    this.onDelete,
    this.loading = false,
    this.title,
    this.newLabel = 'Nuova',
    this.emptyText = 'Nessuna conversazione salvata',
    this.shrinkWrap = false,
    this.dateFormatter,
  });

  final List<CLAiConversationItem> items;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final VoidCallback? onNew;
  final ValueChanged<String>? onArchive;
  final ValueChanged<String>? onDelete;

  /// Mostra l'indicatore di caricamento al posto delle righe.
  final bool loading;
  final String? title;
  final String newLabel;
  final String emptyText;

  /// `true` dentro un foglio o un dialog che si adatta al contenuto.
  final bool shrinkWrap;

  /// Formato della data; di serie relativo («oggi», «ieri», «3g fa», «gg/mm»).
  final String Function(DateTime)? dateFormatter;

  static String relativeDate(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    if (d.year == n.year && d.month == n.month && d.day == n.day) return 'oggi';
    final diff = DateTime(n.year, n.month, n.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    if (diff == 1) return 'ieri';
    if (diff > 1 && diff < 7) return '${diff}g fa';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final showHeader = title != null || onNew != null;

    final Widget list;
    if (loading) {
      list = Padding(
        padding: EdgeInsets.all(theme.gap2Xl),
        child: Center(
          child: SizedBox(
            width: theme.iconSizeLarge,
            height: theme.iconSizeLarge,
            child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
          ),
        ),
      );
    } else if (items.isEmpty) {
      list = Padding(
        padding: EdgeInsets.all(theme.gapLg),
        child: Text(emptyText, style: theme.bodyLabel.copyWith(color: theme.secondaryText)),
      );
    } else {
      list = ListView.builder(
        shrinkWrap: shrinkWrap,
        padding: EdgeInsets.symmetric(horizontal: theme.gapSm, vertical: theme.gapXs),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final c = items[i];
          final selected = c.id == selectedId;
          final second = c.subtitle ?? (c.updatedAt == null ? null : (dateFormatter ?? relativeDate)(c.updatedAt!));
          return Padding(
            padding: EdgeInsets.symmetric(vertical: theme.gapXs / 2),
            child: Material(
              color: selected ? theme.primary.withValues(alpha: theme.opacitySoft) : Colors.transparent,
              borderRadius: BorderRadius.circular(theme.radiusControl),
              child: InkWell(
                key: ValueKey('cl-ai-conv-${c.id}'),
                borderRadius: BorderRadius.circular(theme.radiusControl),
                hoverColor: theme.accent,
                onTap: onSelect == null ? null : () => onSelect!(c.id),
                child: Semantics(
                  selected: selected,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(theme.gapMd, theme.gapSm, theme.gapXs, theme.gapSm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyText.copyWith(
                                  color: selected ? theme.primary : theme.primaryText,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              if (second != null)
                                Text(second, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.smallLabel),
                            ],
                          ),
                        ),
                        if (onArchive != null)
                          CLIconButton(
                            key: ValueKey('cl-ai-conv-${c.id}-archive'),
                            iconData: LucideIcons.archive,
                            tooltip: 'Archivia',
                            backgroundColor: Colors.transparent,
                            iconColor: theme.secondaryText,
                            size: theme.buttonHeightCompact,
                            onTap: () => onArchive!(c.id),
                          ),
                        if (onDelete != null)
                          CLIconButton(
                            key: ValueKey('cl-ai-conv-${c.id}-delete'),
                            iconData: LucideIcons.trash2,
                            tooltip: 'Elimina',
                            backgroundColor: Colors.transparent,
                            iconColor: theme.secondaryText,
                            size: theme.buttonHeightCompact,
                            onTap: () => onDelete!(c.id),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (!showHeader) return list;
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(theme.gapLg, theme.gapMd, theme.gapLg, theme.gapSm),
          child: Row(
            children: [
              Expanded(
                child: Text(title ?? '', style: theme.title.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (onNew != null)
                KeyedSubtree(
                  key: const ValueKey('cl-ai-conv-new'),
                  child: CLSoftButton.primary(
                    text: newLabel,
                    icon: LucideIcons.plus,
                    context: context,
                    isCompact: true,
                    onTap: onNew!,
                  ),
                ),
            ],
          ),
        ),
        shrinkWrap ? Flexible(child: list) : Expanded(child: list),
      ],
    );
  }
}

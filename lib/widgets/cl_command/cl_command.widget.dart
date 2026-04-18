import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_command_item.model.dart';

/// Command palette stile shadcn. Aperta con Ctrl+K su desktop.
class CLCommandPalette extends StatefulWidget {
  final List<CLCommandItem> items;

  const CLCommandPalette({super.key, required this.items});

  static Future<void> show(BuildContext context, List<CLCommandItem> items) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CLCommand',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) => CLCommandPalette(items: items),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  State<CLCommandPalette> createState() => _CLCommandPaletteState();
}

class _CLCommandPaletteState extends State<CLCommandPalette> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  List<CLCommandItem> _filtered = [];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((i) =>
                  i.label.toLowerCase().contains(q.toLowerCase()) ||
                  (i.description?.toLowerCase().contains(q.toLowerCase()) ??
                      false))
              .toList();
      _selected = 0;
    });
  }

  void _selectCurrent() {
    if (_filtered.isEmpty) return;
    _filtered[_selected].onSelect();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Center(
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent) {
            if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() => _selected = (_selected + 1) % (_filtered.isEmpty ? 1 : _filtered.length));
            } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() => _selected =
                  (_selected - 1 + (_filtered.isEmpty ? 1 : _filtered.length)) % (_filtered.isEmpty ? 1 : _filtered.length));
            } else if (e.logicalKey == LogicalKeyboardKey.enter) {
              _selectCurrent();
            }
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 560,
            constraints: const BoxConstraints(maxHeight: 480),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(Sizes.borderRadius + 2),
              border: Border.all(color: theme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: theme.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          focusNode: _focus,
                          onChanged: _onSearch,
                          style: theme.bodyText,
                          decoration: InputDecoration(
                            hintText: 'Cerca azione\u2026',
                            hintStyle: theme.bodyText.copyWith(
                                color: theme.mutedForeground),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.cardBorder),
                if (_filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Nessun risultato',
                        style: theme.bodyLabel,
                        textAlign: TextAlign.center),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(4),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = _filtered[i];
                        final isSelected = i == _selected;
                        return InkWell(
                          onTap: () {
                            item.onSelect();
                            Navigator.of(context).pop();
                          },
                          borderRadius:
                              BorderRadius.circular(Sizes.borderRadius - 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? theme.accent : null,
                              borderRadius:
                                  BorderRadius.circular(Sizes.borderRadius - 2),
                            ),
                            child: Row(
                              children: [
                                if (item.icon != null) ...[
                                  Icon(item.icon,
                                      size: 16,
                                      color: isSelected
                                          ? theme.primaryText
                                          : theme.mutedForeground),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.label, style: theme.title),
                                      if (item.description != null)
                                        Text(item.description!,
                                            style: theme.bodyLabel),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

class GenaiCommand {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<String> keywords;
  final String? group;
  final String? shortcut;
  final FutureOr<void> Function() onInvoke;

  const GenaiCommand({
    required this.id,
    required this.title,
    required this.onInvoke,
    this.subtitle,
    this.icon,
    this.keywords = const [],
    this.group,
    this.shortcut,
  });
}

/// Shows a command palette (§6.6.10) — Cmd+K / Ctrl+K style.
Future<void> showGenaiCommandPalette(
  BuildContext context, {
  required List<GenaiCommand> commands,
  String hint = 'Cerca comando...',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chiudi command palette',
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, _, __) => _CommandPalette(
      commands: commands,
      hint: hint,
    ),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(anim),
        child: child,
      ),
    ),
  );
}

class _CommandPalette extends StatefulWidget {
  final List<GenaiCommand> commands;
  final String hint;
  const _CommandPalette({required this.commands, required this.hint});

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int _highlight = 0;
  String _query = '';

  List<GenaiCommand> get _filtered {
    if (_query.isEmpty) return widget.commands;
    final q = _query.toLowerCase();
    return widget.commands
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            (c.subtitle?.toLowerCase().contains(q) ?? false) ||
            c.keywords.any((k) => k.toLowerCase().contains(q)))
        .toList();
  }

  void _move(int delta) {
    setState(() {
      final list = _filtered;
      if (list.isEmpty) return;
      _highlight = (_highlight + delta) % list.length;
      if (_highlight < 0) _highlight += list.length;
    });
  }

  Future<void> _invokeCurrent() async {
    final list = _filtered;
    if (list.isEmpty) return;
    final cmd = list[_highlight];
    Navigator.of(context).pop();
    await cmd.onInvoke();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final list = _filtered;

    return Align(
      alignment: const Alignment(0, -0.4),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 420),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: context.elevation.shadow(5),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 18, color: colors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (e) {
                          if (e is! KeyDownEvent) return;
                          if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
                            _move(1);
                          } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
                            _move(-1);
                          } else if (e.logicalKey == LogicalKeyboardKey.enter) {
                            _invokeCurrent();
                          } else if (e.logicalKey == LogicalKeyboardKey.escape) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _searchFocus,
                          autofocus: true,
                          style: ty.bodyMd.copyWith(color: colors.textPrimary),
                          cursorColor: colors.colorPrimary,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: widget.hint,
                            hintStyle: ty.bodyMd.copyWith(color: colors.textSecondary),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() {
                            _query = v;
                            _highlight = 0;
                          }),
                          onSubmitted: (_) => _invokeCurrent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: colors.borderDefault),
              Flexible(
                child: list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('Nessun comando', style: ty.bodySm.copyWith(color: colors.textSecondary)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final cmd = list[i];
                          final highlighted = i == _highlight;
                          return MouseRegion(
                            onEnter: (_) => setState(() => _highlight = i),
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await cmd.onInvoke();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                color: highlighted ? colors.surfaceHover : null,
                                child: Row(
                                  children: [
                                    if (cmd.icon != null) ...[
                                      Icon(cmd.icon, size: 18, color: colors.textSecondary),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(cmd.title, style: ty.label.copyWith(color: colors.textPrimary)),
                                          if (cmd.subtitle != null) Text(cmd.subtitle!, style: ty.caption.copyWith(color: colors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    if (cmd.shortcut != null) Text(cmd.shortcut!, style: ty.caption.copyWith(color: colors.textSecondary)),
                                  ],
                                ),
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
    );
  }
}

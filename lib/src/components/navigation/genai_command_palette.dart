import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Single command listed inside a palette. Matched against the live query
/// via [title], [subtitle] and [keywords].
@immutable
class GenaiCommand {
  /// Stable id — useful for analytics.
  final String id;

  /// Visible title (primary match target).
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Additional search keywords (not rendered).
  final List<String> keywords;

  /// Optional group header.
  final String? group;

  /// Optional keyboard shortcut hint displayed trailing.
  final String? shortcut;

  /// Invoked when the command is activated. May return a `Future`; the
  /// palette closes immediately before awaiting.
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

/// Shows the v3 command palette — Cmd/Ctrl+K style.
///
/// Behaviour:
/// - ArrowUp/ArrowDown cycle results
/// - Enter activates the highlighted result
/// - Esc closes (also activates on backdrop tap)
Future<void> showGenaiCommandPalette(
  BuildContext context, {
  required List<GenaiCommand> commands,
  String hint = 'Search commands...',
  String emptyLabel = 'No commands match',
  String? semanticLabel,
}) {
  final motion = context.motion;
  final reduced = GenaiResponsive.reducedMotion(context);
  final colors = context.colors;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close command palette',
    barrierColor: colors.scrimModal,
    transitionDuration: reduced ? Duration.zero : motion.modal.duration,
    pageBuilder: (ctx, _, __) => _CommandPalette(
      commands: commands,
      hint: hint,
      emptyLabel: emptyLabel,
      semanticLabel: semanticLabel,
    ),
    transitionBuilder: (_, anim, __, child) {
      if (reduced) return child;
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: anim, curve: motion.modal.curve),
          ),
          child: child,
        ),
      );
    },
  );
}

class _CommandPalette extends StatefulWidget {
  final List<GenaiCommand> commands;
  final String hint;
  final String emptyLabel;
  final String? semanticLabel;
  const _CommandPalette({
    required this.commands,
    required this.hint,
    required this.emptyLabel,
    required this.semanticLabel,
  });

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final _controller = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  int _highlight = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

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

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(context.motion.hover.duration, () {
      if (!mounted) return;
      setState(() {
        _query = value;
        _highlight = 0;
      });
    });
  }

  Future<void> _invoke(GenaiCommand c) async {
    Navigator.of(context).maybePop();
    await c.onInvoke();
  }

  void _moveHighlight(int delta) {
    final list = _filtered;
    if (list.isEmpty) return;
    setState(() {
      _highlight = (_highlight + delta) % list.length;
      if (_highlight < 0) _highlight += list.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final list = _filtered;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: spacing.s96),
        child: Material(
          color: Colors.transparent,
          child: FocusScope(
            autofocus: true,
            child: Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.arrowDown): _DownIntent(),
                SingleActivator(LogicalKeyboardKey.arrowUp): _UpIntent(),
                SingleActivator(LogicalKeyboardKey.enter): _EnterIntent(),
                SingleActivator(LogicalKeyboardKey.escape): _EscIntent(),
              },
              child: Actions(
                actions: {
                  _DownIntent: CallbackAction<_DownIntent>(
                    onInvoke: (_) {
                      _moveHighlight(1);
                      return null;
                    },
                  ),
                  _UpIntent: CallbackAction<_UpIntent>(
                    onInvoke: (_) {
                      _moveHighlight(-1);
                      return null;
                    },
                  ),
                  _EnterIntent: CallbackAction<_EnterIntent>(
                    onInvoke: (_) {
                      if (list.isNotEmpty &&
                          _highlight >= 0 &&
                          _highlight < list.length) {
                        _invoke(list[_highlight]);
                      }
                      return null;
                    },
                  ),
                  _EscIntent: CallbackAction<_EscIntent>(
                    onInvoke: (_) {
                      Navigator.of(context).maybePop();
                      return null;
                    },
                  ),
                },
                child: Container(
                  width: 640,
                  constraints: const BoxConstraints(maxWidth: 640),
                  decoration: BoxDecoration(
                    color: colors.surfaceModal,
                    borderRadius: BorderRadius.circular(radius.xl),
                    border: Border.all(
                      color: colors.borderDefault,
                      width: sizing.dividerThickness,
                    ),
                    boxShadow: context.elevation.layer3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          spacing.s16,
                          spacing.s12,
                          spacing.s16,
                          spacing.s12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.search,
                              size: sizing.iconSize,
                              color: colors.textTertiary,
                            ),
                            SizedBox(width: spacing.s8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _searchFocus,
                                onChanged: _onQueryChanged,
                                style: ty.body.copyWith(
                                  color: colors.textPrimary,
                                ),
                                cursorColor: colors.colorPrimary,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  hintText: widget.hint,
                                  hintStyle: ty.body.copyWith(
                                    color: colors.textTertiary,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.s6,
                                vertical: spacing.s2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.colorNeutralSubtle,
                                borderRadius: BorderRadius.circular(radius.sm),
                                border: Border.all(
                                  color: colors.borderSubtle,
                                  width: sizing.dividerThickness,
                                ),
                              ),
                              child: Text(
                                'Esc',
                                style: ty.monoSm.copyWith(
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: sizing.dividerThickness,
                        color: colors.borderSubtle,
                      ),
                      if (list.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(spacing.s32),
                          child: Center(
                            child: Text(
                              widget.emptyLabel,
                              style: ty.body.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 360),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                vertical: spacing.s4,
                              ),
                              shrinkWrap: true,
                              itemCount: list.length,
                              itemBuilder: (ctx, i) {
                                final c = list[i];
                                return _CommandRow(
                                  command: c,
                                  selected: i == _highlight,
                                  onTap: () => _invoke(c),
                                  onHover: () {
                                    if (_highlight != i) {
                                      setState(() => _highlight = i);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final GenaiCommand command;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;
  const _CommandRow({
    required this.command,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final bg = selected ? colors.surfaceHover : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: command.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: spacing.s8,
              vertical: spacing.s2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s12,
              vertical: spacing.s8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            child: Row(
              children: [
                if (command.icon != null) ...[
                  Icon(
                    command.icon,
                    size: sizing.iconSize,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: spacing.s12),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        command.title,
                        style: ty.label.copyWith(color: colors.textPrimary),
                      ),
                      if (command.subtitle != null) ...[
                        SizedBox(height: spacing.s2),
                        Text(
                          command.subtitle!,
                          style: ty.bodySm.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (command.shortcut != null) ...[
                  SizedBox(width: spacing.s8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.s6,
                      vertical: spacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorNeutralSubtle,
                      borderRadius: BorderRadius.circular(radius.sm),
                      border: Border.all(
                        color: colors.borderSubtle,
                        width: sizing.dividerThickness,
                      ),
                    ),
                    child: Text(
                      command.shortcut!,
                      style: ty.monoSm.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownIntent extends Intent {
  const _DownIntent();
}

class _UpIntent extends Intent {
  const _UpIntent();
}

class _EnterIntent extends Intent {
  const _EnterIntent();
}

class _EscIntent extends Intent {
  const _EscIntent();
}

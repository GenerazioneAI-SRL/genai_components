part of 'paged_datatable.dart';

/// Action available on a table row.
///
/// Two display modes:
/// - **Popup** (default `inline: false`): rendered inside the 3-dot menu.
///   Provide [content] (typically a `TableActionItem(name, iconData)`).
/// - **Inline** (`inline: true`): rendered directly in the row as a compact
///   `CLOutlineButton`. Provide [label] and optional [icon] (LucideIcons) +
///   optional [color] for tonal variant (e.g. `theme.danger` for "Elimina").
///   The [content] field is unused in inline mode.
class TableAction<T extends Object> {
  final Widget content;
  final void Function(Object) _onTapInternal;

  /// When true, this action renders as a compact `CLOutlineButton` directly
  /// inline in the row, before the 3-dot popup menu.
  final bool inline;

  /// Inline button label (used when [inline] is true).
  final String? label;

  /// Inline button icon (used when [inline] is true).
  final IconData? icon;

  /// Inline button tonal color (used when [inline] is true). Defaults to
  /// `theme.primary`.
  final Color? color;

  TableAction({
    required this.content,
    required void Function(T) onTap,
    this.inline = false,
    this.label,
    this.icon,
    this.color,
  }) : _onTapInternal = ((item) => onTap(item as T));

  void onTap(Object item) => _onTapInternal(item);
}
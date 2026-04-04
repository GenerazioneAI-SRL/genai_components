import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A styled checkbox with optional label, adapted from Skillera's CLCheckbox.
///
/// ```dart
/// CLCheckbox(
///   value: _checked,
///   onChanged: (v) => setState(() => _checked = v),
///   label: 'Accept terms',
/// )
/// ```
class CLCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool tristate;

  const CLCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tristate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    final checkbox = Transform.scale(
      scale: 0.9,
      child: Checkbox(
        value: value,
        tristate: tristate,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        activeColor: theme.primary,
        checkColor: Colors.white,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? theme.primary
                : theme.textSecondary,
            width: states.contains(WidgetState.selected) ? 0 : 1,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        onChanged: onChanged,
      ),
    );

    if (label == null) return checkbox;

    return GestureDetector(
      onTap: onChanged != null
          ? () {
              if (tristate) {
                if (value == null) {
                  onChanged!(false);
                } else if (value == false) {
                  onChanged!(true);
                } else {
                  onChanged!(null);
                }
              } else {
                onChanged!(!(value ?? false));
              }
            }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          SizedBox(width: theme.xs),
          Text(label!, style: theme.bodyText),
        ],
      ),
    );
  }
}

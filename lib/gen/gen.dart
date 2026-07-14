/// Gen wrapper layer entry point.
///
/// - [GenTheme] / [GenThemeData] — the project's single customization surface
///   (skillera tokens), wrapping ShadTheme.
/// - Gen* primitives — 1:1 typedefs over shadcn_ui.
/// - shadcn_ui is re-exported so any Shad* type not yet aliased is still
///   reachable through this one import.
library;

export 'package:shadcn_ui/shadcn_ui.dart';

export 'theme/gen_theme.dart';
export 'theme/gen_tokens.dart';
export 'theme/gen_sizes.dart';
export 'primitives/gen_primitives.dart';
export 'primitives/gen_overlays.dart';

// Custom widget: adaptive shell (migrated from CLAdaptiveShell, logic intact).
export 'shell/gen_adaptive_shell.widget.dart';
export 'shell/gen_nav_tile.widget.dart';
export 'shell/gen_bottom_bar.widget.dart';
export 'shell/gen_destination.dart';
export 'shell/gen_shell_config.dart';
export 'shell/gen_shell_slots.dart';

// Custom widgets migrati (usati dal datatable, riusabili).
export 'widgets/gen_shimmer.dart';
export 'widgets/gen_container.dart';
export 'widgets/gen_popup_surface.dart';
export 'widgets/gen_popup_menu.dart';
export 'widgets/gen_compact_action_scope.dart';
export 'widgets/gen_segmented.dart';
export 'widgets/gen_command_palette.dart';
export 'widgets/gen_ai_assistant.dart';

// Custom widget: paged data table (migrated; theme→Gen; primitives/customs
// still partly on old/ — WIP).
export 'datatable/paged_datatable.dart';

/// Re-exports the canonical icon library used across all Genai components.
///
/// The design system mandates **Lucide Icons** (§3.1.1) and forbids mixing
/// other icon families (Material, FontAwesome, Cupertino) in core widgets.
///
/// Import this file instead of `lucide_icons_flutter` directly so that
/// swapping the underlying package later is a single-file change.
library;

export 'package:lucide_icons_flutter/lucide_icons.dart';

/// Re-exports the canonical icon library used across all v3 components.
///
/// v3 mandates **Lucide Icons** exclusively — matches v2 and the Forma LMS
/// reference HTML (which uses SVG glyphs in the same minimal, line-based
/// Lucide aesthetic). Import this file instead of `lucide_icons_flutter`
/// directly so swapping the underlying package stays a single-file change.
library;

export 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flutter/material.dart';
// Budella Shad: nucleo interno = ShadSheet + showShadSheet (route/slide/barrier/
// draggable nativi). Solo i simboli usati (show). Firma pubblica CLSheet.show
// invariata.
import 'package:shadcn_ui/shadcn_ui.dart' show ShadSheet, ShadSheetSide, showShadSheet;
import '../cl_theme.dart';
import 'cl_popup_surface.widget.dart';

/// Pannello slide-in laterale da destra. Utile per form di dettaglio.
/// Usa [CLSheet.show] per aprirlo.
class CLSheet {
  CLSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    double width = 480,
  }) {
    final theme = CLTheme.of(context);
    return showShadSheet<T>(
      context: context,
      side: ShadSheetSide.right,
      barrierColor: kCLModalScrim,
      builder: (ctx) => ShadSheet(
        // Chrome coerente coi modali CL: secondaryBackground, hairline cardBorder,
        // popoverShadow, radiusModal sul lato libero (sinistro).
        constraints: BoxConstraints(minWidth: width, maxWidth: width),
        backgroundColor: theme.secondaryBackground,
        border: Border.all(color: theme.cardBorder),
        shadows: theme.popoverShadow,
        radius: BorderRadius.only(
          topLeft: Radius.circular(theme.radiusModal),
          bottomLeft: Radius.circular(theme.radiusModal),
        ),
        title: title == null ? null : Text(title, style: theme.heading4),
        child: child,
      ),
    );
  }
}

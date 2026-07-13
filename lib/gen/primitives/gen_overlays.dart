import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Wrapper Gen sulle funzioni overlay di Shad (le funzioni non sono
/// typedef-abili, quindi le si avvolge per usare SOLO nomi Gen nel codice).
/// Inoltrano l'intera superficie di `showShadDialog`/`showShadSheet`.

/// Apre un [GenDialog]/[ShadDialog] come rotta modale. Vedi `showShadDialog`.
Future<T?> showGenDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0xcc000000),
  String barrierLabel = '',
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  ShadDialogVariant variant = ShadDialogVariant.primary,
  bool opaque = false,
}) {
  return showShadDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    variant: variant,
    opaque: opaque,
  );
}

/// Apre un [GenSheet]/[ShadSheet]. Vedi `showShadSheet`.
Future<T?> showGenSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ShadSheetSide? side,
  Color? backgroundColor,
  String barrierLabel = '',
  ShapeBorder? shape,
  Color barrierColor = const Color(0xcc000000),
  bool useRootNavigator = false,
  bool isDismissible = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showShadSheet<T>(
    context: context,
    builder: builder,
    side: side,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    shape: shape,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

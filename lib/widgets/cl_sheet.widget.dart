import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
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
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CLSheet',
      barrierColor: kCLModalScrim,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _CLSheetWidget(title: title, width: width, child: child),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: child);
      },
    );
  }
}

class _CLSheetWidget extends StatelessWidget {
  final Widget child;
  final String? title;
  final double width;

  const _CLSheetWidget({
    required this.child,
    this.title,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    // Modal chrome coerente: radiusModal sul lato libero (sinistro),
    // bordo hairline e theme.cardShadow come gli altri modali.
    final radius = BorderRadius.only(
      topLeft: Radius.circular(theme.radiusModal),
      bottomLeft: Radius.circular(theme.radiusModal),
    );
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: radius,
            border: Border.all(color: theme.cardBorder),
            boxShadow: theme.popoverShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.padding, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: theme.cardBorder)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title!, style: theme.heading4),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                        color: theme.mutedForeground,
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                              theme.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Sizes.padding),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

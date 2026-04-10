import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../widgets/buttons/cl_button.widget.dart';
import '../widgets/buttons/cl_outline_button.widget.dart';
import '../widgets/buttons/cl_ghost_button.widget.dart';

/// Azione contestuale di pagina — usata per creare bottoni nel CLPageHeader.
class PageAction {
  final String title;
  final IconData? iconData;
  final VoidCallback? onTap;
  final bool isMain;
  final bool isSecondary;
  final bool needConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;
  final Color? color;

  PageAction({
    required this.title,
    this.iconData,
    this.onTap,
    this.isMain = false,
    this.isSecondary = false,
    this.needConfirmation = false,
    this.confirmationTitle,
    this.confirmationMessage,
    this.color,
  });

  /// Wrapper per rendere onTap compatibile con `dynamic Function()`.
  dynamic Function() _wrapOnTap(VoidCallback? callback) => () => callback?.call();

  /// Converte in widget bottone appropriato in base ai flag.
  Widget toWidget(BuildContext context) {
    final theme = CLTheme.of(context);
    final buttonColor = color ?? theme.primary;
    final tapHandler = needConfirmation ? _wrapOnTap(() => _showConfirmation(context)) : _wrapOnTap(onTap);

    if (isSecondary) {
      return CLGhostButton(
        text: title,
        onTap: tapHandler,
        context: context,
        iconData: iconData,
        color: buttonColor,
        iconAlignment: IconAlignment.start,
      );
    }

    if (isMain) {
      return CLButton.primary(
        text: title,
        onTap: tapHandler,
        context: context,
        icon: iconData,
        iconAlignment: IconAlignment.start,
      );
    }

    return CLOutlineButton.secondary(
      text: title,
      onTap: tapHandler,
      context: context,
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirmationTitle ?? 'Conferma'),
        content: Text(confirmationMessage ?? 'Sei sicuro di voler procedere?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onTap?.call();
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }
}


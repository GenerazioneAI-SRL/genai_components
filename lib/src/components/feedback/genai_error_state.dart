import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_button.dart';

/// Error state with retry action (§6.4.4).
class GenaiErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? errorCode;
  final VoidCallback? onRetry;
  final Widget? secondaryAction;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const GenaiErrorState({
    super.key,
    this.title = 'Si è verificato un errore',
    this.description,
    this.errorCode,
    this.onRetry,
    this.secondaryAction,
    this.icon = LucideIcons.circleAlert,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.colorErrorSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: colors.colorError),
            ),
            const SizedBox(height: 16),
            Text(title, style: ty.headingSm.copyWith(color: colors.textPrimary), textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(description!, style: ty.bodyMd.copyWith(color: colors.textSecondary), textAlign: TextAlign.center),
              ),
            ],
            if (errorCode != null) ...[
              const SizedBox(height: 8),
              Text('Codice: $errorCode', style: ty.code.copyWith(color: colors.textSecondary)),
            ],
            if (onRetry != null || secondaryAction != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (secondaryAction != null) secondaryAction!,
                  if (onRetry != null)
                    GenaiButton.primary(
                      label: 'Riprova',
                      icon: LucideIcons.refreshCw,
                      onPressed: onRetry,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

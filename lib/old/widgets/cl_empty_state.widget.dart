import 'package:flutter/material.dart';

import '../cl_theme.dart';

/// Stato vuoto standard — **Tier 1**.
///
/// Icona (opzionale) + titolo + messaggio (opzionale) + azione (opzionale),
/// centrati, con spaziatura e tipografia dai token. Sostituisce i tanti
/// `Center(child: Text('Nessun ...'))` ad-hoc sparsi nelle pagine, dando un
/// layout coerente e uno slot azione.
///
/// Esempi:
/// ```dart
/// // Minimo — drop-in per "Nessun X":
/// CLEmptyState(title: 'Nessuna sede')
///
/// // Completo:
/// CLEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'Nessun accreditamento',
///   message: 'Aggiungi il primo accreditamento per iniziare.',
///   action: CLButton.primary(text: 'Aggiungi', onTap: _add, context: context),
/// )
/// ```
class CLEmptyState extends StatelessWidget {
  const CLEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.iconColor,
    this.compact = false,
  });

  /// Titolo principale (es. "Nessuna sede").
  final String title;

  /// Descrizione opzionale sotto il titolo.
  final String? message;

  /// Icona opzionale sopra il titolo.
  final IconData? icon;

  /// Azione opzionale (tipicamente un `CLButton`/`CLOutlineButton`).
  final Widget? action;

  /// Tinta di icona. Default `theme.mutedForeground`.
  final Color? iconColor;

  /// Layout denso (dentro card/tab piccole): icona e spaziature ridotte.
  final bool compact;

  /// Larghezza massima del blocco testo per una lunghezza di riga leggibile.
  static const double _maxContentWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final tint = iconColor ?? theme.mutedForeground;
    final iconSize = compact ? theme.iconSizeDefault : theme.iconSizeLarge;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? theme.gapLg : theme.gap2Xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: tint),
                SizedBox(height: compact ? theme.gapSm : theme.gapLg),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.title.copyWith(fontWeight: FontWeight.w600),
              ),
              if (message != null) ...[
                SizedBox(height: theme.gapXs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.bodyLabel,
                ),
              ],
              if (action != null) ...[
                SizedBox(height: compact ? theme.gapLg : theme.gap2Xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

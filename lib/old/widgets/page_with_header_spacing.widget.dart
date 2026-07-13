import 'package:flutter/material.dart';

/// Widget che aggiunge automaticamente lo spazio per l'header con blur
/// Usa questo per wrappare il contenuto delle pagine scrollabili
class PageWithHeaderSpacing extends StatelessWidget {
  const PageWithHeaderSpacing({
    super.key,
    required this.child,
    this.headerHeight = 125.0,
  });

  final Widget child;
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: headerHeight),
      child: child,
    );
  }
}

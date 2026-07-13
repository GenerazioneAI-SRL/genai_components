import 'package:flutter/material.dart';

/// Wrapper che centra il contenuto con un maxWidth e padding laterale fisso.
/// Usa questo come root delle pagine shell per evitare che il contenuto
/// si allarghi troppo su monitor ultrawide.
class CLPageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  const CLPageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1280.0,
    this.horizontalPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

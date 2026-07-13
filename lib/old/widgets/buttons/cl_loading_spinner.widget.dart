import 'package:flutter/cupertino.dart';

class CLLoadingSpinner extends StatelessWidget {
  const CLLoadingSpinner({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: size / 2.6,
          color: color,
        ),
      ),
    );
  }
}



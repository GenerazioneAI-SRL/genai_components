import 'package:flutter/material.dart';

import '../cl_theme.dart';

class DetailElement extends StatefulWidget {
  const DetailElement({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  State<DetailElement> createState() => _DetailElementState();
}

class _DetailElementState extends State<DetailElement> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: CLTheme.of(context).bodyLabel,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
      subtitle: Text(
        widget.value,
        style: CLTheme.of(context).bodyText,
        overflow: TextOverflow.fade,
        maxLines: 1,
      ),
    );
  }
}

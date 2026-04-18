import 'package:flutter/material.dart';

class CLCommandItem {
  final String id;
  final String label;
  final String? description;
  final IconData? icon;
  final VoidCallback onSelect;
  final String? group;

  const CLCommandItem({
    required this.id,
    required this.label,
    this.description,
    this.icon,
    required this.onSelect,
    this.group,
  });
}

import 'package:flutter/material.dart';

/// Declarative module definition for Skillera routing.
class CLModule {
  final String name;
  final String path;
  final List<CLModulePage> pages;

  const CLModule({
    required this.name,
    required this.path,
    required this.pages,
  });
}

/// A page inside a module.
class CLModulePage {
  final String name;
  final String path;
  final Widget Function(BuildContext context) builder;
  final bool showInSidebar;
  final String? group;
  final List<CLModulePage> children;

  const CLModulePage({
    required this.name,
    required this.path,
    required this.builder,
    this.showInSidebar = true,
    this.group,
    this.children = const [],
  });
}

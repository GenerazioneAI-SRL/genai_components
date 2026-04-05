class BreadcrumbItem {
  final String name;
  final String path;
  final bool isModule;
  final bool isClickable;

  const BreadcrumbItem({required this.name, required this.path, this.isModule = false, this.isClickable = true});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BreadcrumbItem) return false;
    return other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'BreadcrumbItem($name, $path, module=$isModule)';
}

import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/router/go_router_modular/route_registry.dart';

void main() {
  group('RouteRegistry', () {
    setUp(() {
      RouteRegistry.instance.clear();
    });

    test('registerRoute stores name -> path mapping', () {
      RouteRegistry.instance.registerRoute('home', '/');
      expect(RouteRegistry.instance.has('home'), isTrue);
      expect(RouteRegistry.instance.getPathByName('home'), '/');
    });

    test('has() returns false for unknown route', () {
      expect(RouteRegistry.instance.has('nonexistent'), isFalse);
    });

    test('has() returns true for a registered full path', () {
      RouteRegistry.instance.registerRoute('users', '/admin/users');
      expect(RouteRegistry.instance.has('/admin/users'), isTrue);
    });

    test('factory and instance return same singleton', () {
      RouteRegistry.instance.registerRoute('shared', '/shared');
      expect(RouteRegistry().has('shared'), isTrue);
      expect(identical(RouteRegistry(), RouteRegistry.instance), isTrue);
    });

    test('registering same name with different path does not throw', () {
      RouteRegistry.instance.registerRoute('test', '/a');
      expect(
        () => RouteRegistry.instance.registerRoute('test', '/b'),
        returnsNormally,
      );
      // Both paths retained; most specific (longest) returned by default.
      expect(RouteRegistry.instance.getPathByName('test'), '/b'.length > '/a'.length ? '/b' : '/a');
    });

    test('getPathByName picks the longest path when multiple registered', () {
      RouteRegistry.instance.registerRoute('detail', '/detail');
      RouteRegistry.instance.registerRoute('detail', '/admin/detail/edit');
      expect(
        RouteRegistry.instance.getPathByName('detail'),
        '/admin/detail/edit',
      );
    });

    test('getPathByName uses contextPath to pick best prefix match', () {
      RouteRegistry.instance.registerRoute('list', '/admin/list');
      RouteRegistry.instance.registerRoute('list', '/public/list');
      expect(
        RouteRegistry.instance.getPathByName('list', contextPath: '/admin/foo'),
        '/admin/list',
      );
      expect(
        RouteRegistry.instance.getPathByName('list', contextPath: '/public/foo'),
        '/public/list',
      );
    });

    test('getAllRoutes returns unmodifiable map', () {
      RouteRegistry.instance.registerRoute('only', '/only');
      final all = RouteRegistry.instance.getAllRoutes();
      expect(all.containsKey('only'), isTrue);
      expect(() => all['x'] = ['/x'], throwsUnsupportedError);
    });

    test('clear empties the registry', () {
      RouteRegistry.instance.registerRoute('k', '/k');
      RouteRegistry.instance.clear();
      expect(RouteRegistry.instance.has('k'), isFalse);
      expect(RouteRegistry.instance.getPathByName('k'), isNull);
    });
  });
}

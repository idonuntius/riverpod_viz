import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz/riverpod_viz.dart';

void main() {
  group('RiverpodVizObserver', () {
    test('instantiation - creates an instance of RiverpodVizObserver', () {
      final observer = RiverpodVizObserver();
      expect(observer, isA<RiverpodVizObserver>());
    });
  });
}

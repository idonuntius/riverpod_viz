import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz/riverpod_viz.dart';

void main() {
  group('ProviderEventType', () {
    test('values - contains four event types', () {
      expect(ProviderEventType.values.length, 4);
    });

    test('add.value - returns "add"', () {
      expect(ProviderEventType.add.value, 'add');
    });

    test('update.value - returns "update"', () {
      expect(ProviderEventType.update.value, 'update');
    });

    test('dispose.value - returns "dispose"', () {
      expect(ProviderEventType.dispose.value, 'dispose');
    });

    test('error.value - returns "error"', () {
      expect(ProviderEventType.error.value, 'error');
    });

    test('values are unique - no duplicates across enum values', () {
      final values = ProviderEventType.values.map((e) => e.value).toSet();
      expect(values.length, ProviderEventType.values.length);
    });
  });
}

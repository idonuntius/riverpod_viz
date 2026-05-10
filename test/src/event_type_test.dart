import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz/riverpod_viz.dart';

void main() {
  group('ProviderEventType', () {
    test('全てのenum値が定義されている - 4つのイベントタイプが存在する', () {
      expect(ProviderEventType.values.length, 4);
    });

    test('add.value - "add"が返る', () {
      expect(ProviderEventType.add.value, 'add');
    });

    test('update.value - "update"が返る', () {
      expect(ProviderEventType.update.value, 'update');
    });

    test('dispose.value - "dispose"が返る', () {
      expect(ProviderEventType.dispose.value, 'dispose');
    });

    test('error.value - "error"が返る', () {
      expect(ProviderEventType.error.value, 'error');
    });

    test('各valueが一意である - 重複がない', () {
      final values = ProviderEventType.values.map((e) => e.value).toSet();
      expect(values.length, ProviderEventType.values.length);
    });
  });
}

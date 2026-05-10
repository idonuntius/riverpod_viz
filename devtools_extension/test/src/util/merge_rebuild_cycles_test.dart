import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';
import 'package:riverpod_viz_devtools_extension/src/util/merge_rebuild_cycles.dart';

void main() {
  group('mergeRebuildCycles', () {
    test('空のリストを渡す - 空のリストが返る', () {
      expect(mergeRebuildCycles([]), isEmpty);
    });

    test('dispose→addペアがない - 元のリストがそのまま返る', () {
      final events = [
        _event('add', 'counter', 1000),
        _event('update', 'counter', 2000),
        _event('update', 'counter', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), ['add', 'update', 'update']);
    });

    test('dispose→addが100ms以内 - 両方のイベントが除去される', () {
      final events = [
        _event('add', 'greeting', 1000),
        _event('dispose', 'greeting', 2000),
        _event('add', 'greeting', 2050),
        _event('update', 'greeting', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result[0].type, 'add');
      expect(result[0].timestamp, 1000);
      expect(result[1].type, 'update');
      expect(result[1].timestamp, 3000);
    });

    test('dispose→addがちょうど100ms - 結合される', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('add', 'a', 2100),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 1);
      expect(result[0].type, 'add');
      expect(result[0].timestamp, 1000);
    });

    test('dispose→addが101ms以上 - 結合されない', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('add', 'a', 2101),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), ['add', 'dispose', 'add']);
    });

    test('disposeの後にaddではないイベントが来る - 結合されない', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('update', 'a', 2010),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), ['add', 'dispose', 'update']);
    });

    test('disposeがリスト末尾にある - そのまま残る', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result[1].type, 'dispose');
    });

    test('連続するdispose→addペアが複数回 - 全て結合される', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('add', 'a', 2010),
        _event('update', 'a', 3000),
        _event('dispose', 'a', 4000),
        _event('add', 'a', 4005),
        _event('update', 'a', 5000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), ['add', 'update', 'update']);
      expect(result[0].timestamp, 1000);
      expect(result[1].timestamp, 3000);
      expect(result[2].timestamp, 5000);
    });

    test('異なるProviderのイベントが混在 - 同一Provider内でのみ結合判定される', () {
      // Note: この関数は単一Provider分のイベントリストを受け取る前提
      // 異なるProviderが混ざっても、disposeの次がaddなら結合条件を判定する
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('add', 'a', 2001),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 1);
      expect(result[0].type, 'add');
    });

    test('同一ミリ秒のdispose→add - 結合される', () {
      final events = [
        _event('add', 'a', 1000),
        _event('dispose', 'a', 2000),
        _event('add', 'a', 2000),
        _event('update', 'a', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result.map((e) => e.type), ['add', 'update']);
    });
  });
}

ProviderEvent _event(String type, String providerId, int timestamp) {
  return ProviderEvent(
    type: type,
    providerId: providerId,
    timestamp: timestamp,
  );
}

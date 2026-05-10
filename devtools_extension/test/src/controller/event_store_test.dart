import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/controller/event_store.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';

void main() {
  late EventStore store;

  setUp(() {
    store = EventStore();
  });

  tearDown(() {
    store.dispose();
  });

  group('eventsByProvider', () {
    test('イベントが空 - 空のMapが返る', () {
      expect(store.eventsByProvider, isEmpty);
    });

    test('同じProviderの複数イベント - 1つのキーにグループ化される', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('update', 'counter', 2000))
        ..addEvent(_event('update', 'counter', 3000));

      final map = store.eventsByProvider;

      expect(map.keys, ['counter']);
      expect(map['counter']!.length, 3);
    });

    test('異なるProviderのイベント - それぞれのキーに分かれる', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000));

      final map = store.eventsByProvider;

      expect(map.keys.length, 2);
      expect(map['counter']!.length, 1);
      expect(map['greeting']!.length, 1);
    });
  });

  group('orderedProviderIds', () {
    test('イベントが空 - 空のリストが返る', () {
      expect(store.orderedProviderIds, isEmpty);
    });

    test('異なるタイムスタンプでaddされる - 最初のイベント順にソートされる', () {
      store
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'async', 3000));

      expect(store.orderedProviderIds, ['counter', 'greeting', 'async']);
    });
  });

  group('aliveProviderCount', () {
    test('イベントが空 - 0が返る', () {
      expect(store.aliveProviderCount, 0);
    });

    test('addイベントのみ - 全てカウントされる', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000));

      expect(store.aliveProviderCount, 2);
    });

    test('addの後にdisposeされる - カウントから除外される', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'greeting', 3000));

      expect(store.aliveProviderCount, 1);
    });

    test('disposeの後に再度addされる - 再カウントされる', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('dispose', 'counter', 2000))
        ..addEvent(_event('add', 'counter', 3000));

      expect(store.aliveProviderCount, 1);
    });

    test('updateイベントがある - aliveカウントに影響しない', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('update', 'counter', 2000));

      expect(store.aliveProviderCount, 1);
    });

    test('全てdisposeされる - 0が返る', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'counter', 3000))
        ..addEvent(_event('dispose', 'greeting', 4000));

      expect(store.aliveProviderCount, 0);
    });
  });

  group('startTime / endTime', () {
    test('イベントが空 - 両方0が返る', () {
      expect(store.startTime, 0);
      expect(store.endTime, 0);
    });

    test('複数イベントがある - startTimeは最小値、endTimeは最大値が返る', () {
      store
        ..addEvent(_event('add', 'a', 3000))
        ..addEvent(_event('add', 'b', 1000))
        ..addEvent(_event('update', 'a', 5000));

      expect(store.startTime, 1000);
      expect(store.endTime, 5000);
    });
  });

  group('clear', () {
    test('alive状態のProviderがある - 合成addイベントが再挿入される', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'greeting', 3000));

      store.clear();

      expect(store.events.length, 1);
      expect(store.events.first.providerId, 'counter');
      expect(store.events.first.type, 'add');
    });

    test('全てdisposeされている - イベントが全て削除される', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('dispose', 'counter', 2000));

      store.clear();

      expect(store.events, isEmpty);
    });

    test('clear後もaliveProviderCountが維持される', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('update', 'counter', 3000));

      store.clear();

      expect(store.aliveProviderCount, 2);
    });
  });

  group('notifyListeners', () {
    test('addEventを呼ぶ - リスナーが通知される', () {
      var notified = false;
      store.addListener(() => notified = true);

      store.addEvent(_event('add', 'counter', 1000));

      expect(notified, isTrue);
    });

    test('clearを呼ぶ - リスナーが通知される', () {
      store.addEvent(_event('add', 'counter', 1000));
      var notified = false;
      store.addListener(() => notified = true);

      store.clear();

      expect(notified, isTrue);
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

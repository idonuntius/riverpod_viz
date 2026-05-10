import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/controller/event_store.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event_type.dart';

void main() {
  late EventStore store;

  setUp(() {
    store = EventStore();
  });

  tearDown(() {
    store.dispose();
  });

  group('eventsByProvider', () {
    test('no events - returns an empty Map', () {
      expect(store.eventsByProvider, isEmpty);
    });

    test('multiple events for the same provider - grouped under one key', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('update', 'counter', 2000))
        ..addEvent(_event('update', 'counter', 3000));

      final map = store.eventsByProvider;

      expect(map.keys, ['counter']);
      expect(map['counter']!.length, 3);
    });

    test('events for different providers - split into separate keys', () {
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
    test('no events - returns an empty list', () {
      expect(store.orderedProviderIds, isEmpty);
    });

    test(
        'providers added at different timestamps - sorted by first-event timestamp',
        () {
      store
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'async', 3000));

      expect(store.orderedProviderIds, ['counter', 'greeting', 'async']);
    });
  });

  group('aliveProviderCount', () {
    test('no events - returns 0', () {
      expect(store.aliveProviderCount, 0);
    });

    test('add events only - all are counted', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000));

      expect(store.aliveProviderCount, 2);
    });

    test('dispose after add - removed from the count', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'greeting', 3000));

      expect(store.aliveProviderCount, 1);
    });

    test('add after dispose - counted again', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('dispose', 'counter', 2000))
        ..addEvent(_event('add', 'counter', 3000));

      expect(store.aliveProviderCount, 1);
    });

    test('update event - does not affect the alive count', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('update', 'counter', 2000));

      expect(store.aliveProviderCount, 1);
    });

    test('all providers disposed - returns 0', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'counter', 3000))
        ..addEvent(_event('dispose', 'greeting', 4000));

      expect(store.aliveProviderCount, 0);
    });
  });

  group('startTime / endTime', () {
    test('no events - both return 0', () {
      expect(store.startTime, 0);
      expect(store.endTime, 0);
    });

    test('multiple events - startTime is the min and endTime is the max', () {
      store
        ..addEvent(_event('add', 'a', 3000))
        ..addEvent(_event('add', 'b', 1000))
        ..addEvent(_event('update', 'a', 5000));

      expect(store.startTime, 1000);
      expect(store.endTime, 5000);
    });
  });

  group('clear', () {
    test('alive providers exist - synthetic add events are re-emitted', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('dispose', 'greeting', 3000));

      store.clear();

      expect(store.events.length, 1);
      expect(store.events.first.providerId, 'counter');
      expect(store.events.first.type, ProviderEventType.add);
    });

    test('all providers already disposed - all events are removed', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('dispose', 'counter', 2000));

      store.clear();

      expect(store.events, isEmpty);
    });

    test('aliveProviderCount preserved after clear', () {
      store
        ..addEvent(_event('add', 'counter', 1000))
        ..addEvent(_event('add', 'greeting', 2000))
        ..addEvent(_event('update', 'counter', 3000));

      store.clear();

      expect(store.aliveProviderCount, 2);
    });
  });

  group('notifyListeners', () {
    test('addEvent - notifies listeners', () {
      var notified = false;
      store.addListener(() => notified = true);

      store.addEvent(_event('add', 'counter', 1000));

      expect(notified, isTrue);
    });

    test('clear - notifies listeners', () {
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
    type: ProviderEventType.fromWire(type),
    providerId: providerId,
    timestamp: timestamp,
  );
}

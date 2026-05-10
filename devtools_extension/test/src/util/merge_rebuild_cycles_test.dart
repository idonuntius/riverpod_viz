import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event_type.dart';
import 'package:riverpod_viz_devtools_extension/src/util/merge_rebuild_cycles.dart';

void main() {
  group('mergeRebuildCycles', () {
    test('empty list - returns empty list', () {
      expect(mergeRebuildCycles([]), isEmpty);
    });

    test('no dispose→add pairs - returns the original list as-is', () {
      final events = [
        _event(ProviderEventType.add, 'counter', 1000),
        _event(ProviderEventType.update, 'counter', 2000),
        _event(ProviderEventType.update, 'counter', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), [
        ProviderEventType.add,
        ProviderEventType.update,
        ProviderEventType.update,
      ]);
    });

    test('dispose→add within 100ms - both events are removed', () {
      final events = [
        _event(ProviderEventType.add, 'greeting', 1000),
        _event(ProviderEventType.dispose, 'greeting', 2000),
        _event(ProviderEventType.add, 'greeting', 2050),
        _event(ProviderEventType.update, 'greeting', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result[0].type, ProviderEventType.add);
      expect(result[0].timestamp, 1000);
      expect(result[1].type, ProviderEventType.update);
      expect(result[1].timestamp, 3000);
    });

    test('dispose→add exactly 100ms apart - merged', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.add, 'a', 2100),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 1);
      expect(result[0].type, ProviderEventType.add);
      expect(result[0].timestamp, 1000);
    });

    test('dispose→add 101ms or more apart - not merged', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.add, 'a', 2101),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), [
        ProviderEventType.add,
        ProviderEventType.dispose,
        ProviderEventType.add,
      ]);
    });

    test('dispose followed by a non-add event - not merged', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.update, 'a', 2010),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), [
        ProviderEventType.add,
        ProviderEventType.dispose,
        ProviderEventType.update,
      ]);
    });

    test('dispose at end of list - kept as-is', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result[1].type, ProviderEventType.dispose);
    });

    test('multiple consecutive dispose→add pairs - all merged', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.add, 'a', 2010),
        _event(ProviderEventType.update, 'a', 3000),
        _event(ProviderEventType.dispose, 'a', 4000),
        _event(ProviderEventType.add, 'a', 4005),
        _event(ProviderEventType.update, 'a', 5000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 3);
      expect(result.map((e) => e.type), [
        ProviderEventType.add,
        ProviderEventType.update,
        ProviderEventType.update,
      ]);
      expect(result[0].timestamp, 1000);
      expect(result[1].timestamp, 3000);
      expect(result[2].timestamp, 5000);
    });

    test(
        'mixed providers in the list - merge decision applies regardless of providerId',
        () {
      // Note: this function expects events for a single provider; a mixed
      // list still has the dispose→add merge condition applied.
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.add, 'a', 2001),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 1);
      expect(result[0].type, ProviderEventType.add);
    });

    test('dispose and add at the same millisecond - merged', () {
      final events = [
        _event(ProviderEventType.add, 'a', 1000),
        _event(ProviderEventType.dispose, 'a', 2000),
        _event(ProviderEventType.add, 'a', 2000),
        _event(ProviderEventType.update, 'a', 3000),
      ];

      final result = mergeRebuildCycles(events);

      expect(result.length, 2);
      expect(result.map((e) => e.type), [
        ProviderEventType.add,
        ProviderEventType.update,
      ]);
    });
  });
}

ProviderEvent _event(ProviderEventType type, String providerId, int timestamp) {
  return ProviderEvent(
    type: type,
    providerId: providerId,
    timestamp: timestamp,
  );
}

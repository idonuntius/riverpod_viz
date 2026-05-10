import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event_type.dart';

void main() {
  group('ProviderEventType', () {
    test('values - contains four event types', () {
      expect(ProviderEventType.values.length, 4);
      expect(
        ProviderEventType.values.toSet(),
        {
          ProviderEventType.add,
          ProviderEventType.update,
          ProviderEventType.dispose,
          ProviderEventType.error,
        },
      );
    });

    test('add.wireValue - returns "add"', () {
      expect(ProviderEventType.add.wireValue, 'add');
    });

    test('update.wireValue - returns "update"', () {
      expect(ProviderEventType.update.wireValue, 'update');
    });

    test('dispose.wireValue - returns "dispose"', () {
      expect(ProviderEventType.dispose.wireValue, 'dispose');
    });

    test('error.wireValue - returns "error"', () {
      expect(ProviderEventType.error.wireValue, 'error');
    });

    test('wireValues are unique - no duplicates across enum values', () {
      final wires = ProviderEventType.values.map((e) => e.wireValue).toSet();
      expect(wires.length, ProviderEventType.values.length);
    });

    group('fromWire', () {
      test('"add" - returns ProviderEventType.add', () {
        expect(ProviderEventType.fromWire('add'), ProviderEventType.add);
      });

      test('"update" - returns ProviderEventType.update', () {
        expect(ProviderEventType.fromWire('update'), ProviderEventType.update);
      });

      test('"dispose" - returns ProviderEventType.dispose', () {
        expect(
          ProviderEventType.fromWire('dispose'),
          ProviderEventType.dispose,
        );
      });

      test('"error" - returns ProviderEventType.error', () {
        expect(ProviderEventType.fromWire('error'), ProviderEventType.error);
      });

      test('unknown wire value - throws ArgumentError', () {
        expect(
          () => ProviderEventType.fromWire('unknown'),
          throwsArgumentError,
        );
      });

      test('empty string - throws ArgumentError', () {
        expect(() => ProviderEventType.fromWire(''), throwsArgumentError);
      });

      test('case-sensitive - "Add" throws ArgumentError', () {
        expect(() => ProviderEventType.fromWire('Add'), throwsArgumentError);
      });

      test('round-trips for every enum value', () {
        for (final type in ProviderEventType.values) {
          expect(ProviderEventType.fromWire(type.wireValue), type);
        }
      });
    });
  });
}

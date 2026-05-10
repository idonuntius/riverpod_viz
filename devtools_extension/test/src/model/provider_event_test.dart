import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event_type.dart';

void main() {
  group('ProviderEvent', () {
    test('fromJson with valid JSON - creates instance with correct fields',
        () {
      final json = <String, Object?>{
        'type': 'add',
        'provider_id': 'counter',
        'timestamp': 1000,
      };

      final event = ProviderEvent.fromJson(json);

      expect(event.type, ProviderEventType.add);
      expect(event.providerId, 'counter');
      expect(event.timestamp, 1000);
    });

    test('fromJson with unknown type - throws ArgumentError', () {
      final json = <String, Object?>{
        'type': 'unknown',
        'provider_id': 'counter',
        'timestamp': 1000,
      };

      expect(() => ProviderEvent.fromJson(json), throwsArgumentError);
    });

    test('toJson - returns a Map round-trippable via fromJson', () {
      const event = ProviderEvent(
        type: ProviderEventType.update,
        providerId: 'greeting',
        timestamp: 2000,
      );

      final json = event.toJson();

      expect(json['type'], 'update');
      expect(json['provider_id'], 'greeting');
      expect(json['timestamp'], 2000);
    });

    test('round-trip toJson and fromJson - restores the same field values',
        () {
      const original = ProviderEvent(
        type: ProviderEventType.dispose,
        providerId: 'userProfile(42)',
        timestamp: 3000,
      );

      final restored = ProviderEvent.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(restored.providerId, original.providerId);
      expect(restored.timestamp, original.timestamp);
    });

    test('toString - includes type, providerId, and timestamp', () {
      const event = ProviderEvent(
        type: ProviderEventType.error,
        providerId: 'asyncData',
        timestamp: 5000,
      );

      final str = event.toString();

      expect(str, contains('error'));
      expect(str, contains('asyncData'));
      expect(str, contains('5000'));
    });
  });
}

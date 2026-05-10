import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_viz_devtools_extension/src/model/provider_event.dart';

void main() {
  group('ProviderEvent', () {
    test('fromJsonに有効なJSONを渡す - 正しいフィールドでインスタンスが生成される', () {
      final json = <String, Object?>{
        'type': 'add',
        'provider_id': 'counter',
        'timestamp': 1000,
      };

      final event = ProviderEvent.fromJson(json);

      expect(event.type, 'add');
      expect(event.providerId, 'counter');
      expect(event.timestamp, 1000);
    });

    test('toJsonを呼ぶ - fromJsonで復元可能なMapが返る', () {
      const event = ProviderEvent(
        type: 'update',
        providerId: 'greeting',
        timestamp: 2000,
      );

      final json = event.toJson();

      expect(json['type'], 'update');
      expect(json['provider_id'], 'greeting');
      expect(json['timestamp'], 2000);
    });

    test('toJsonの結果をfromJsonに渡す - 同じ値のインスタンスが復元される', () {
      const original = ProviderEvent(
        type: 'dispose',
        providerId: 'userProfile(42)',
        timestamp: 3000,
      );

      final restored = ProviderEvent.fromJson(original.toJson());

      expect(restored.type, original.type);
      expect(restored.providerId, original.providerId);
      expect(restored.timestamp, original.timestamp);
    });

    test('toStringを呼ぶ - type, providerId, timestampが含まれる', () {
      const event = ProviderEvent(
        type: 'error',
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

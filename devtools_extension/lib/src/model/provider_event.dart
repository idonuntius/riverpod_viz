import 'provider_event_type.dart';

/// A single provider lifecycle event received from the host app.
class ProviderEvent {
  /// Creates a provider event with the given [type], [providerId], and
  /// [timestamp].
  const ProviderEvent({
    required this.type,
    required this.providerId,
    required this.timestamp,
  });

  /// The kind of lifecycle event (add / update / dispose / error).
  final ProviderEventType type;

  /// The provider's identifier string (e.g. `counterProvider` or
  /// `userProfile(42)` for family providers).
  final String providerId;

  /// The event time in milliseconds since the Unix epoch.
  final int timestamp;

  /// Decodes a [ProviderEvent] from the JSON payload posted by
  /// `RiverpodVizObserver`.
  factory ProviderEvent.fromJson(Map<String, Object?> json) {
    return ProviderEvent(
      type: ProviderEventType.fromWire(json['type'] as String),
      providerId: json['provider_id'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  /// Encodes this event back to the wire JSON shape.
  Map<String, Object?> toJson() => {
        'type': type.wireValue,
        'provider_id': providerId,
        'timestamp': timestamp,
      };

  @override
  String toString() =>
      'ProviderEvent(${type.wireValue}, $providerId, $timestamp)';
}

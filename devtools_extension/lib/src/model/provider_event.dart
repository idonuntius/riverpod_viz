class ProviderEvent {
  const ProviderEvent({
    required this.type,
    required this.providerId,
    required this.timestamp,
  });

  final String type;
  final String providerId;
  final int timestamp;

  factory ProviderEvent.fromJson(Map<String, Object?> json) {
    return ProviderEvent(
      type: json['type'] as String,
      providerId: json['provider_id'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, Object?> toJson() => {
        'type': type,
        'provider_id': providerId,
        'timestamp': timestamp,
      };

  @override
  String toString() => 'ProviderEvent($type, $providerId, $timestamp)';
}

/// The type of provider lifecycle event decoded from the wire payload.
///
/// Mirrors `ProviderEventType` in the published `riverpod_viz` library; the
/// shared contract is the [wireValue] string posted via
/// `dart:developer.postEvent`.
enum ProviderEventType {
  /// A provider was created and added to the scope.
  add('add'),

  /// A provider's value changed.
  update('update'),

  /// A provider was disposed and removed from the scope.
  dispose('dispose'),

  /// A provider threw during its build.
  error('error');

  /// Creates an event type with its [wireValue].
  const ProviderEventType(this.wireValue);

  /// The wire-format string identifying this event type.
  final String wireValue;

  /// Decodes a [ProviderEventType] from its wire-format [value].
  ///
  /// Throws [ArgumentError] if [value] does not correspond to a known type.
  static ProviderEventType fromWire(String value) {
    return ProviderEventType.values.firstWhere(
      (e) => e.wireValue == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown event type'),
    );
  }
}

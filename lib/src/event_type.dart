/// The type of provider lifecycle event reported by [RiverpodVizObserver].
enum ProviderEventType {
  /// A provider was created and added to the scope.
  add('add'),

  /// A provider's value changed.
  update('update'),

  /// A provider was disposed and removed from the scope.
  dispose('dispose'),

  /// A provider threw during its build.
  error('error');

  /// Creates an event type with its wire-format string [value].
  const ProviderEventType(this.value);

  /// The string sent on the wire (in `dart:developer.postEvent` payloads)
  /// to identify this event type.
  final String value;
}

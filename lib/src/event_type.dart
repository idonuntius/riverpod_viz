/// The type of provider lifecycle event.
enum ProviderEventType {
  add('add'),
  update('update'),
  dispose('dispose'),
  error('error');

  const ProviderEventType(this.value);

  final String value;
}

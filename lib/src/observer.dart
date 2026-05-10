import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event_type.dart';

/// A [ProviderObserver] that posts lifecycle events via
/// `dart:developer.postEvent` for the riverpod_viz DevTools extension.
///
/// Add an instance to your `ProviderScope.observers` to make provider
/// add / update / dispose / error events visible in the DevTools timeline.
base class RiverpodVizObserver extends ProviderObserver {
  /// Posts a [ProviderEventType.add] event when a provider is created.
  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    _post(ProviderEventType.add, context);
  }

  /// Posts a [ProviderEventType.update] event when a provider's value changes.
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _post(ProviderEventType.update, context);
  }

  /// Posts a [ProviderEventType.dispose] event when a provider is disposed.
  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _post(ProviderEventType.dispose, context);
  }

  /// Posts a [ProviderEventType.error] event when a provider throws.
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _post(ProviderEventType.error, context);
  }

  void _post(ProviderEventType type, ProviderObserverContext context) {
    final data = <String, Object?>{
      'type': type.value,
      'provider_id': context.provider.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    developer.postEvent(
      'riverpod_viz:provider_event',
      data,
    );
  }
}

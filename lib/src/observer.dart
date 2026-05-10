import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event_type.dart';

/// A [ProviderObserver] that posts lifecycle events via
/// `dart:developer.postEvent` for the riverpod_viz DevTools extension.
base class RiverpodVizObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    _post(ProviderEventType.add, context);
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _post(ProviderEventType.update, context);
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _post(ProviderEventType.dispose, context);
  }

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

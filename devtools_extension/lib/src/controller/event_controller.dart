import 'dart:async';
import 'dart:math';

import 'package:devtools_extensions/devtools_extensions.dart';

import '../model/provider_event.dart';
import '../model/provider_event_type.dart';
import 'event_store.dart';

/// An [EventStore] that subscribes to the host app's
/// `riverpod_viz:provider_event` extension events and feeds them into the
/// store.
///
/// Also supports a mock-data mode for previewing the UI without a connected
/// app.
class EventController extends EventStore {
  /// Creates a controller with no active subscription. Call [startListening]
  /// to begin receiving events.
  EventController();

  StreamSubscription<Object?>? _subscription;
  bool _useMockData = false;
  Timer? _mockTimer;

  /// Whether mock data is currently being generated.
  bool get useMockData => _useMockData;

  /// Subscribes to the VM service's extension event stream and forwards
  /// `riverpod_viz:provider_event` payloads into the store.
  Future<void> startListening() async {
    final service = await serviceManager.onServiceAvailable;
    _subscription = service.onExtensionEvent.listen((event) {
      if (event.extensionKind == 'riverpod_viz:provider_event') {
        final data = event.extensionData?.data;
        if (data != null) {
          addEvent(ProviderEvent.fromJson(Map<String, Object?>.from(data)));
        }
      }
    });
  }

  /// Cancels the extension event subscription, if any.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Toggles mock data generation on or off.
  ///
  /// When turned on, a fixed set of synthetic providers is seeded and a 2-second
  /// timer emits random `add` / `update` / `dispose` events.
  void toggleMockData() {
    _useMockData = !_useMockData;
    if (_useMockData) {
      _startMockData();
    } else {
      _mockTimer?.cancel();
      _mockTimer = null;
    }
    notifyListeners();
  }

  void _startMockData() {
    final rng = Random();
    final providers = [
      'counterProvider',
      'greetingProvider',
      'asyncDataProvider',
      'userProfile(1)',
      'userProfile(42)',
    ];

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final p in providers) {
      addEvent(ProviderEvent(
        type: ProviderEventType.add,
        providerId: p,
        timestamp: now,
      ));
    }

    _mockTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final provider = providers[rng.nextInt(providers.length)];
      const types = [
        ProviderEventType.update,
        ProviderEventType.dispose,
        ProviderEventType.add,
      ];
      final type = types[rng.nextInt(types.length)];
      addEvent(ProviderEvent(
        type: type,
        providerId: provider,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }

  @override
  void dispose() {
    stopListening();
    _mockTimer?.cancel();
    super.dispose();
  }
}

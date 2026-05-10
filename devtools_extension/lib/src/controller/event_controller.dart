import 'dart:async';
import 'dart:math';

import 'package:devtools_extensions/devtools_extensions.dart';

import '../model/provider_event.dart';
import 'event_store.dart';

class EventController extends EventStore {
  EventController();

  StreamSubscription<Object?>? _subscription;
  bool _useMockData = false;
  Timer? _mockTimer;

  bool get useMockData => _useMockData;

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

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

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
      addEvent(ProviderEvent(type: 'add', providerId: p, timestamp: now));
    }

    _mockTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final provider = providers[rng.nextInt(providers.length)];
      final types = ['update', 'dispose', 'add'];
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

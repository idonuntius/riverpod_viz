import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/provider_event.dart';

class EventStore extends ChangeNotifier {
  EventStore();

  final List<ProviderEvent> _events = [];

  List<ProviderEvent> get events => List.unmodifiable(_events);

  void addEvent(ProviderEvent event) {
    _events.add(event);
    notifyListeners();
  }

  Map<String, List<ProviderEvent>> get eventsByProvider {
    final map = <String, List<ProviderEvent>>{};
    for (final event in _events) {
      map.putIfAbsent(event.providerId, () => []).add(event);
    }
    return map;
  }

  List<String> get orderedProviderIds {
    final byProvider = eventsByProvider;
    final entries = byProvider.entries.toList()
      ..sort((a, b) {
        final aFirst = a.value.first.timestamp;
        final bFirst = b.value.first.timestamp;
        return aFirst.compareTo(bFirst);
      });
    return entries.map((e) => e.key).toList();
  }

  int get aliveProviderCount {
    final alive = <String>{};
    for (final event in _events) {
      switch (event.type) {
        case 'add':
          alive.add(event.providerId);
        case 'dispose':
          alive.remove(event.providerId);
        default:
          break;
      }
    }
    return alive.length;
  }

  int get startTime =>
      _events.isEmpty ? 0 : _events.map((e) => e.timestamp).reduce(min);

  int get endTime =>
      _events.isEmpty ? 0 : _events.map((e) => e.timestamp).reduce(max);

  void clear() {
    final aliveProviders = <String>{};
    for (final event in _events) {
      switch (event.type) {
        case 'add':
          aliveProviders.add(event.providerId);
        case 'dispose':
          aliveProviders.remove(event.providerId);
        default:
          break;
      }
    }
    _events.clear();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in aliveProviders) {
      _events.add(ProviderEvent(type: 'add', providerId: id, timestamp: now));
    }
    notifyListeners();
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/provider_event.dart';
import '../model/provider_event_type.dart';

/// Holds the running list of [ProviderEvent]s and exposes derived views
/// (per-provider grouping, ordering, alive count, time range) used by the
/// timeline UI.
///
/// Notifies listeners whenever events are added or cleared.
class EventStore extends ChangeNotifier {
  /// Creates an empty event store.
  EventStore();

  final List<ProviderEvent> _events = [];

  /// All events received so far, in arrival order. Returned as an unmodifiable
  /// view.
  List<ProviderEvent> get events => List.unmodifiable(_events);

  /// Appends [event] to the store and notifies listeners.
  void addEvent(ProviderEvent event) {
    _events.add(event);
    notifyListeners();
  }

  /// Events grouped by their `providerId`, preserving insertion order within
  /// each group.
  Map<String, List<ProviderEvent>> get eventsByProvider {
    final map = <String, List<ProviderEvent>>{};
    for (final event in _events) {
      map.putIfAbsent(event.providerId, () => []).add(event);
    }
    return map;
  }

  /// Provider IDs ordered by the timestamp of the first event seen for each
  /// provider (oldest first). This is the row order used by the chart.
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

  /// The number of providers currently alive (added but not yet disposed).
  int get aliveProviderCount {
    final alive = <String>{};
    for (final event in _events) {
      switch (event.type) {
        case ProviderEventType.add:
          alive.add(event.providerId);
        case ProviderEventType.dispose:
          alive.remove(event.providerId);
        case ProviderEventType.update:
        case ProviderEventType.error:
          break;
      }
    }
    return alive.length;
  }

  /// Earliest event timestamp (ms since epoch), or `0` if empty.
  int get startTime =>
      _events.isEmpty ? 0 : _events.map((e) => e.timestamp).reduce(min);

  /// Latest event timestamp (ms since epoch), or `0` if empty.
  int get endTime =>
      _events.isEmpty ? 0 : _events.map((e) => e.timestamp).reduce(max);

  /// Clears the timeline while keeping currently-alive providers tracked.
  ///
  /// Synthetic `add` events at "now" are re-emitted for each alive provider so
  /// they continue to appear in the timeline after the clear.
  void clear() {
    final aliveProviders = <String>{};
    for (final event in _events) {
      switch (event.type) {
        case ProviderEventType.add:
          aliveProviders.add(event.providerId);
        case ProviderEventType.dispose:
          aliveProviders.remove(event.providerId);
        case ProviderEventType.update:
        case ProviderEventType.error:
          break;
      }
    }
    _events.clear();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in aliveProviders) {
      _events.add(ProviderEvent(
        type: ProviderEventType.add,
        providerId: id,
        timestamp: now,
      ));
    }
    notifyListeners();
  }
}

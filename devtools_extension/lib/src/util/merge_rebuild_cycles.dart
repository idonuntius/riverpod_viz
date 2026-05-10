import '../model/provider_event.dart';
import '../model/provider_event_type.dart';

/// Merge DISPOSE→ADD pairs within 100ms into continuous sequences.
/// This handles autoDispose providers that get disposed and immediately
/// re-created when a dependency changes.
List<ProviderEvent> mergeRebuildCycles(List<ProviderEvent> events) {
  final merged = <ProviderEvent>[];
  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    if (event.type == ProviderEventType.dispose &&
        i + 1 < events.length &&
        events[i + 1].type == ProviderEventType.add &&
        (events[i + 1].timestamp - event.timestamp) <= 100) {
      i++; // skip DISPOSE and the following ADD
      continue;
    }
    merged.add(event);
  }
  return merged;
}

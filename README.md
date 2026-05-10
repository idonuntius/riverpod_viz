# riverpod_viz

A [DevTools extension](https://docs.flutter.dev/tools/devtools/extensions) that visualizes [Riverpod](https://riverpod.dev/) provider lifecycles as a Gantt-chart-style timeline.

[![pub package](https://img.shields.io/pub/v/riverpod_viz.svg)](https://pub.dev/packages/riverpod_viz)

## Features

- **Timeline visualization** — See when providers are created, updated, and disposed as horizontal bars on a time axis.
- **Event markers** — Individual add / update / dispose / error events are shown as points on each bar with tooltip details.
- **Family provider support** — Family providers are displayed separately with their arguments (e.g. `userProfile(42)`).
- **Auto-scroll** — The timeline automatically follows new events when scrolled to the latest position.
- **Clear & resume** — Clear the timeline while keeping alive providers tracked.

## Screenshot

<!-- TODO: Add screenshot -->

## Getting Started

### 1. Add the dependency

```yaml
dependencies:
  riverpod_viz: ^0.1.0
```

### 2. Register the observer

Add `RiverpodVizObserver` to your `ProviderScope`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_viz/riverpod_viz.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [RiverpodVizObserver()],
      child: const MyApp(),
    ),
  );
}
```

### 3. Open DevTools

Run your app in debug mode, open Flutter DevTools, and select the **riverpod_viz** tab.

## Provider Names

By default, providers are displayed using their runtime type. For more readable names, use the `name` parameter:

```dart
final counterProvider = NotifierProvider<Counter, int>(
  Counter.new,
  name: 'counter',
);
```

Family providers automatically include their arguments:

```dart
final userProvider = FutureProvider.autoDispose.family<User, int>(
  (ref, userId) => fetchUser(userId),
  name: 'user',
);
// Displayed as: user(42)
```

## Requirements

- Flutter 1.17.0 or later
- Dart SDK 3.11.5 or later
- `flutter_riverpod` 3.3.1 or later

## License

MIT — see [LICENSE](LICENSE) for details.

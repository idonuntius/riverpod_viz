import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_viz/riverpod_viz.dart';

// --- Providers ---

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
  name: 'counter',
);

final greetingProvider = Provider.autoDispose<String>(
  (ref) {
    final count = ref.watch(counterProvider);
    return 'Hello! Count is $count';
  },
  name: 'greeting',
);

final asyncDataProvider = FutureProvider.autoDispose<String>(
  (ref) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return 'Loaded at ${DateTime.now()}';
  },
  name: 'asyncData',
);

final detailTimerProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream.periodic(const Duration(seconds: 1), (i) => i),
  name: 'detailTimer',
);

class DetailNoteNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final detailNoteProvider = NotifierProvider<DetailNoteNotifier, String>(
  DetailNoteNotifier.new,
  name: 'detailNote',
);

final onDemandProvider = FutureProvider.autoDispose<String>(
  (ref) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'On-demand data ready';
  },
  name: 'onDemand',
);

final userProfileProvider =
    FutureProvider.autoDispose.family<String, int>(
  (ref, userId) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'User #$userId profile';
  },
  name: 'userProfile',
);

// --- App ---

void main() {
  runApp(
    ProviderScope(
      observers: [RiverpodVizObserver()],
      child: const ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'riverpod_viz Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final greeting = ref.watch(greetingProvider);
    final asyncData = ref.watch(asyncDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('riverpod_viz Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Count: $count', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(greeting),
            const SizedBox(height: 8),
            asyncData.when(
              data: (data) => Text('Async: $data'),
              loading: () => const Text('Async: Loading...'),
              error: (e, _) => Text('Async error: $e'),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      ref.read(counterProvider.notifier).increment(),
                  child: const Text('Increment'),
                ),
                ElevatedButton(
                  onPressed: () => ref.invalidate(asyncDataProvider),
                  child: const Text('Reload Async'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const DetailPage()),
                  ),
                  child: const Text('Go to Detail'),
                ),
                ElevatedButton(
                  onPressed: () => ref.read(onDemandProvider),
                  child: const Text('Load On-Demand'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(detailTimerProvider);
    final note = ref.watch(detailNoteProvider);
    final user1 = ref.watch(userProfileProvider(1));
    final user42 = ref.watch(userProfileProvider(42));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            timer.when(
              data: (t) => Text('Timer: $t s'),
              loading: () => const Text('Timer: starting...'),
              error: (e, _) => Text('Timer error: $e'),
            ),
            const SizedBox(height: 8),
            user1.when(
              data: (d) => Text(d),
              loading: () => const Text('Loading user 1...'),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 8),
            user42.when(
              data: (d) => Text(d),
              loading: () => const Text('Loading user 42...'),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            Text('Note: $note'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Edit note',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(detailNoteProvider.notifier).update(v),
            ),
          ],
        ),
      ),
    );
  }
}

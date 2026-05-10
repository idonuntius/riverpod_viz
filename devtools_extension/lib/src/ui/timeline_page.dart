import 'package:flutter/material.dart';

import '../controller/event_controller.dart';
import 'timeline_chart.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _controller = EventController();
  final _scrollController = ScrollController();
  bool _isAtRightEdge = true;

  @override
  void initState() {
    super.initState();
    _controller.startListening();
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final atEdge = pos.pixels >= pos.maxScrollExtent - 4;
    if (atEdge != _isAtRightEdge) {
      setState(() => _isAtRightEdge = atEdge);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventCount = _controller.events.length;
    final providerCount = _controller.orderedProviderIds.length;
    final aliveCount = _controller.aliveProviderCount;

    return Scaffold(
      body: Column(
        children: [
          // Toolbar.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Text(
                  'Riverpod Timeline',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chart.
          Expanded(
            child: _controller.events.isEmpty
                ? const Center(
                    child: Text(
                      'Waiting for Riverpod events...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : TimelineChart(
                    controller: _controller,
                    scrollController: _scrollController,
                  ),
          ),
          const Divider(height: 1),
          // Status bar.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Text(
                  '$eventCount events, $providerCount providers ($aliveCount alive)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_isAtRightEdge && _controller.events.isNotEmpty
          ? FloatingActionButton.small(
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              tooltip: 'Scroll to latest',
              child: const Icon(Icons.keyboard_double_arrow_right),
            )
          : null,
    );
  }
}

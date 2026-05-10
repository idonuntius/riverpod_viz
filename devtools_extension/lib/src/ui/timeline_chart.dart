import 'dart:math';

import 'package:flutter/material.dart';

import '../controller/event_controller.dart';
import '../model/provider_event.dart';
import '../util/merge_rebuild_cycles.dart';

const double _rowHeight = 28.0;
const double _barHeight = 14.0;
const double _leftMargin = 24.0;
const double _pxPerSecond = 60.0;
const double _labelWidth = 160.0;

const Color _barColor1 = Color(0xFF4078C0);
const Color _barColor2 = Color(0xFF2E9E6E);

class TimelineChart extends StatefulWidget {
  const TimelineChart({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  final EventController controller;
  final ScrollController scrollController;

  @override
  State<TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  Offset? _hoverPosition;
  _HitEvent? _hitEvent;
  bool _isAtRightEdge = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    _isAtRightEdge = pos.pixels >= pos.maxScrollExtent - 4;
  }

  @override
  void didUpdateWidget(covariant TimelineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isAtRightEdge && widget.scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          widget.scrollController
              .jumpTo(widget.scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  double _chartWidth() {
    final c = widget.controller;
    if (c.events.isEmpty) return 600;
    final durationMs = c.endTime - c.startTime;
    final durationPx = (durationMs / 1000.0) * _pxPerSecond;
    return max(600, durationPx + _leftMargin + 100);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final providerIds = controller.orderedProviderIds;
    final chartHeight = max(providerIds.length * _rowHeight + 30, 100.0);
    final chartWidth = _chartWidth();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed label column.
        SizedBox(
          width: _labelWidth,
          height: chartHeight,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: providerIds.length,
            itemExtent: _rowHeight,
            itemBuilder: (context, index) {
              final id = providerIds[index];
              return Tooltip(
                message: id,
                waitDuration: const Duration(milliseconds: 300),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: Text(
                    id,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // Scrollable bars area.
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            child: MouseRegion(
              onHover: (event) => _onHover(event.localPosition, controller),
              onExit: (_) => setState(() {
                _hoverPosition = null;
                _hitEvent = null;
              }),
              child: SizedBox(
                width: chartWidth,
                height: chartHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(chartWidth, chartHeight),
                      painter: _BarsPainter(
                        controller: controller,
                        hitEvent: _hitEvent,
                      ),
                    ),
                    if (_hitEvent != null && _hoverPosition != null)
                      _buildTooltip(chartWidth, chartHeight),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onHover(Offset localPosition, EventController controller) {
    final providerIds = controller.orderedProviderIds;
    final byProvider = controller.eventsByProvider;
    final startTime = controller.startTime;

    final rowIndex = (localPosition.dy / _rowHeight).floor();
    if (rowIndex < 0 || rowIndex >= providerIds.length) {
      setState(() {
        _hoverPosition = null;
        _hitEvent = null;
      });
      return;
    }

    final providerId = providerIds[rowIndex];
    final events = byProvider[providerId] ?? [];

    final merged = mergeRebuildCycles(events);

    // Build set of events within active segments.
    final eventsInSegments = <ProviderEvent>[];
    bool inSegment = false;
    for (final event in merged) {
      if (event.type == 'add') {
        inSegment = true;
        eventsInSegments.add(event);
      } else if (event.type == 'dispose') {
        if (inSegment) eventsInSegments.add(event);
        inSegment = false;
      } else {
        if (inSegment) eventsInSegments.add(event);
      }
    }

    // Find nearest event point within 8px.
    _HitEvent? best;
    double bestDist = double.infinity;

    for (final event in eventsInSegments) {
      final x = _leftMargin +
          ((event.timestamp - startTime) / 1000.0) * _pxPerSecond;
      final y = rowIndex * _rowHeight + _rowHeight / 2;
      final dist =
          sqrt(pow(localPosition.dx - x, 2) + pow(localPosition.dy - y, 2));
      if (dist < 8 && dist < bestDist) {
        bestDist = dist;
        best = _HitEvent(event: event, providerId: providerId);
      }
    }

    setState(() {
      _hoverPosition = localPosition;
      _hitEvent = best;
    });
  }

  Widget _buildTooltip(double chartWidth, double chartHeight) {
    final hit = _hitEvent!;
    final event = hit.event;
    final dt = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
    final typeLabel = '[${event.type.toUpperCase()}]';
    final dateStr =
        '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}.${_pad3(dt.millisecond)}';

    final controller = widget.controller;
    final relativeMs = event.timestamp - controller.startTime;
    final relativeStr = '${(relativeMs / 1000.0).toStringAsFixed(1)}s';

    const tooltipWidth = 260.0;
    const tooltipHeight = 54.0;

    double tx = _hoverPosition!.dx + 12;
    double ty = _hoverPosition!.dy - tooltipHeight - 4;
    if (tx + tooltipWidth > chartWidth) {
      tx = _hoverPosition!.dx - tooltipWidth - 12;
    }
    if (ty < 0) ty = _hoverPosition!.dy + 16;

    return Positioned(
      left: tx,
      top: ty,
      child: IgnorePointer(
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$typeLabel ${hit.providerId}\n$dateStr ($relativeStr)',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _pad3(int n) => n.toString().padLeft(3, '0');
}

class _HitEvent {
  const _HitEvent({required this.event, required this.providerId});
  final ProviderEvent event;
  final String providerId;
}


class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.controller, this.hitEvent});

  final EventController controller;
  final _HitEvent? hitEvent;

  @override
  void paint(Canvas canvas, Size size) {
    final providerIds = controller.orderedProviderIds;
    final byProvider = controller.eventsByProvider;
    final startTime = controller.startTime;
    final endTime = controller.endTime;

    if (providerIds.isEmpty) return;

    final durationMs = endTime - startTime;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // Draw time axis ticks.
    _drawTimeAxis(canvas, size, startTime, durationMs);

    // Draw bars per provider.
    for (var i = 0; i < providerIds.length; i++) {
      final id = providerIds[i];
      final events = byProvider[id] ?? [];
      final y = i * _rowHeight + (_rowHeight - _barHeight) / 2;
      final isHovered = hitEvent?.providerId == id;

      final color = i.isEven ? _barColor1 : _barColor2;
      final barPaint = Paint()
        ..color = color.withValues(alpha: isHovered ? 1.0 : 0.55);

      final merged = mergeRebuildCycles(events);

      // Build bar segments and collect events within segments.
      final segments = <(int start, int end)>[];
      final eventsInSegments = <ProviderEvent>[];
      int? segStart;
      for (final event in merged) {
        if (event.type == 'add') {
          segStart = event.timestamp;
          eventsInSegments.add(event);
        } else if (event.type == 'dispose') {
          if (segStart != null) {
            segments.add((segStart, event.timestamp));
            eventsInSegments.add(event);
          }
          segStart = null;
        } else {
          // update/error: only include if within an active segment.
          if (segStart != null) {
            eventsInSegments.add(event);
          }
        }
      }
      if (segStart != null) {
        segments.add((segStart, nowMs));
      }

      // Draw bar segments.
      for (final (start, end) in segments) {
        _drawBar(canvas, start, end, startTime, y, barPaint);
      }

      // Draw event markers (only for events within segments).
      final markerBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final markerFillPaint = Paint()..color = Colors.white;
      final markerCenterPaint = Paint()..color = color;
      for (final event in eventsInSegments) {
        final x = _leftMargin +
            ((event.timestamp - startTime) / 1000.0) * _pxPerSecond;
        final cy = i * _rowHeight + _rowHeight / 2;
        canvas.drawCircle(Offset(x, cy), 4, markerFillPaint);
        canvas.drawCircle(Offset(x, cy), 2.5, markerCenterPaint);
        canvas.drawCircle(Offset(x, cy), 4, markerBorderPaint);
      }
    }
  }

  void _drawBar(Canvas canvas, int segStartMs, int segEndMs, int startTime,
      double y, Paint paint) {
    final x1 =
        _leftMargin + ((segStartMs - startTime) / 1000.0) * _pxPerSecond;
    final x2 = _leftMargin + ((segEndMs - startTime) / 1000.0) * _pxPerSecond;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x1, y, max(x2 - x1, 2), _barHeight),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  void _drawTimeAxis(
      Canvas canvas, Size size, int startTime, int durationMs) {
    final labelStyle = TextStyle(color: Colors.grey[600], fontSize: 10);
    final majorLinePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 0.5;
    final minorLinePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;
    final tickHeight = size.height - 20;

    final durationSec = durationMs / 1000.0;
    final maxSec = durationSec + 2;

    // Minor ticks every 1s, major ticks with label every 5s.
    for (var sec = 0; sec <= maxSec; sec++) {
      final x = _leftMargin + sec * _pxPerSecond;
      if (x > size.width) break;

      final isMajor = sec % 5 == 0;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, tickHeight),
        isMajor ? majorLinePaint : minorLinePaint,
      );

      if (isMajor) {
        final label = '${sec}s';
        final tp = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, tickHeight + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) => true;
}

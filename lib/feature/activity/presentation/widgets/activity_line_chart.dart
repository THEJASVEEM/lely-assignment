import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lely_assignment/feature/activity/domain/entities/robot_activity.dart';

const double _leftPadding = 44;
const double _rightPadding = 16;
const double _topPadding = 20;
const double _bottomPadding = 36;

class ActivityLineChart extends StatefulWidget {
  const ActivityLineChart({required this.activities, super.key});

  final List<RobotActivity> activities;

  @override
  State<ActivityLineChart> createState() => _ActivityLineChartState();
}

class _ActivityLineChartState extends State<ActivityLineChart> {
  int? _hoveredIndex;

  void _updateHover(Offset localPosition, Size size) {
    final geometry = _ChartGeometry.compute(widget.activities, size);

    var closestIndex = 0;
    var closestDistance = double.infinity;

    for (var index = 0; index < geometry.points.length; index++) {
      final distance = (geometry.points[index].dx - localPosition.dx).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = index;
      }
    }

    final withinChartArea =
        localPosition.dx >= _leftPadding &&
        localPosition.dx <= size.width - _rightPadding &&
        localPosition.dy >= 0 &&
        localPosition.dy <= size.height - _bottomPadding;

    final nextHoveredIndex = withinChartArea ? closestIndex : null;

    if (nextHoveredIndex != _hoveredIndex) {
      setState(() => _hoveredIndex = nextHoveredIndex);
    }
  }

  void _clearHover() {
    if (_hoveredIndex != null) {
      setState(() => _hoveredIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activities.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(child: Text('No activity available for this range')),
      );
    }

    return SizedBox(
      height: 320,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 320);

          return MouseRegion(
            onHover: (event) => _updateHover(event.localPosition, size),
            onExit: (_) => _clearHover(),
            child: GestureDetector(
              onPanDown: (details) => _updateHover(details.localPosition, size),
              onPanUpdate: (details) =>
                  _updateHover(details.localPosition, size),
              onPanEnd: (_) => _clearHover(),
              onPanCancel: _clearHover,
              child: CustomPaint(
                painter: ActivityLineChartPainter(
                  activities: widget.activities,
                  lineColor: Theme.of(context).colorScheme.primary,
                  gridColor: Theme.of(context).colorScheme.outlineVariant,
                  labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  tooltipColor: Theme.of(context).colorScheme.inverseSurface,
                  tooltipTextColor: Theme.of(
                    context,
                  ).colorScheme.onInverseSurface,
                  hoveredIndex: _hoveredIndex,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ActivityLineChartPainter extends CustomPainter {
  ActivityLineChartPainter({
    required this.activities,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
    required this.tooltipColor,
    required this.tooltipTextColor,
    this.hoveredIndex,
  });

  final List<RobotActivity> activities;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;
  final Color tooltipColor;
  final Color tooltipTextColor;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _leftPadding - _rightPadding;
    final chartHeight = size.height - _topPadding - _bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0 || activities.isEmpty) {
      return;
    }

    final geometry = _ChartGeometry.compute(activities, size);
    final points = geometry.points;

    _drawGrid(
      canvas: canvas,
      chartWidth: chartWidth,
      chartHeight: chartHeight,
      yAxisMaximum: geometry.yAxisMaximum,
    );

    _drawGradient(canvas: canvas, points: points, chartHeight: chartHeight);

    _drawLine(canvas, points);
    _drawPoints(canvas, points);
    _drawXAxisLabels(canvas: canvas, size: size, points: points);

    if (hoveredIndex != null && hoveredIndex! < points.length) {
      _drawHoveredPoint(canvas, points[hoveredIndex!]);
      _drawTooltip(
        canvas: canvas,
        size: size,
        index: hoveredIndex!,
        point: points[hoveredIndex!],
      );
    }
  }

  void _drawGrid({
    required Canvas canvas,
    required double chartWidth,
    required double chartHeight,
    required double yAxisMaximum,
  }) {
    const gridLineCount = 4;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    for (var index = 0; index <= gridLineCount; index++) {
      final fraction = index / gridLineCount;
      final y = _topPadding + chartHeight * fraction;

      canvas.drawLine(
        Offset(_leftPadding, y),
        Offset(_leftPadding + chartWidth, y),
        gridPaint,
      );

      final value = yAxisMaximum * (1 - fraction);

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: TextStyle(color: labelColor, fontSize: 11),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          _leftPadding - textPainter.width - 8,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawGradient({
    required Canvas canvas,
    required List<Offset> points,
    required double chartHeight,
  }) {
    if (points.isEmpty) {
      return;
    }

    final baselineY = _topPadding + chartHeight;

    final fillPath = Path()
      ..moveTo(points.first.dx, baselineY)
      ..lineTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }

    fillPath
      ..lineTo(points.last.dx, baselineY)
      ..close();

    final bounds = Rect.fromLTRB(
      points.first.dx,
      _topPadding,
      points.last.dx == points.first.dx ? points.last.dx + 1 : points.last.dx,
      baselineY,
    );

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(bounds);

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawLine(Canvas canvas, List<Offset> points) {
    if (points.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(linePath, linePaint);
  }

  void _drawPoints(Canvas canvas, List<Offset> points) {
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3.5, pointPaint);
    }
  }

  void _drawHoveredPoint(Canvas canvas, Offset point) {
    final haloPaint = Paint()..color = lineColor.withValues(alpha: 0.15);
    canvas.drawCircle(point, 10, haloPaint);

    final ringPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(point, 5.5, ringPaint);

    final corePaint = Paint()..color = lineColor;
    canvas.drawCircle(point, 3.5, corePaint);
  }

  void _drawTooltip({
    required Canvas canvas,
    required Size size,
    required int index,
    required Offset point,
  }) {
    final activity = activities[index];
    final dateLabel = DateFormat('dd MMM yyyy').format(activity.date);
    final durationLabel = '${activity.durationHours.toStringAsFixed(1)}h';

    final textPainter =
        TextPainter(
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.center,
          )
          ..text = TextSpan(
            children: [
              TextSpan(
                text: '$dateLabel\n',
                style: TextStyle(
                  color: tooltipTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: durationLabel,
                style: TextStyle(
                  color: tooltipTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
          ..layout();

    const horizontalPadding = 10.0;
    const verticalPadding = 6.0;
    const pointGap = 12.0;

    final bubbleWidth = textPainter.width + horizontalPadding * 2;
    final bubbleHeight = textPainter.height + verticalPadding * 2;

    var bubbleTop = point.dy - pointGap - bubbleHeight;
    if (bubbleTop < 0) {
      // Not enough room above the point, place the tooltip below it instead.
      bubbleTop = point.dy + pointGap;
    }

    final bubbleLeft = (point.dx - bubbleWidth / 2).clamp(
      0.0,
      size.width - bubbleWidth,
    );

    final bubbleRect = Rect.fromLTWH(
      bubbleLeft,
      bubbleTop,
      bubbleWidth,
      bubbleHeight,
    );
    final bubbleRRect = RRect.fromRectAndRadius(
      bubbleRect,
      const Radius.circular(6),
    );

    final bubblePaint = Paint()..color = tooltipColor;
    canvas.drawRRect(bubbleRRect, bubblePaint);

    textPainter.paint(
      canvas,
      Offset(
        bubbleRect.left + horizontalPadding,
        bubbleRect.top + verticalPadding,
      ),
    );
  }

  void _drawXAxisLabels({
    required Canvas canvas,
    required Size size,
    required List<Offset> points,
  }) {
    final labelIndexes = _labelIndexes(activities.length);

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (final index in labelIndexes) {
      final label = DateFormat('dd MMM').format(activities[index].date);

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(color: labelColor, fontSize: 11),
      );

      textPainter.layout(maxWidth: 56);

      final point = points[index];

      textPainter.paint(
        canvas,
        Offset(
          (point.dx - textPainter.width / 2).clamp(
            0,
            size.width - textPainter.width,
          ),
          size.height - _bottomPadding + 10,
        ),
      );
    }
  }

  Set<int> _labelIndexes(int length) {
    if (length <= 1) {
      return {0};
    }

    if (length <= 4) {
      return Set<int>.from(List<int>.generate(length, (index) => index));
    }

    return {0, (length - 1) ~/ 3, ((length - 1) * 2) ~/ 3, length - 1};
  }

  @override
  bool shouldRepaint(covariant ActivityLineChartPainter oldDelegate) {
    return !listEquals(oldDelegate.activities, activities) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.tooltipColor != tooltipColor ||
        oldDelegate.tooltipTextColor != tooltipTextColor ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}

class _ChartGeometry {
  const _ChartGeometry({required this.points, required this.yAxisMaximum});

  final List<Offset> points;
  final double yAxisMaximum;

  static _ChartGeometry compute(List<RobotActivity> activities, Size size) {
    final chartWidth = size.width - _leftPadding - _rightPadding;
    final chartHeight = size.height - _topPadding - _bottomPadding;

    final maxHours = activities
        .map((activity) => activity.durationHours)
        .fold<double>(0, math.max);

    final yAxisMaximum = maxHours <= 0
        ? 1.0
        : ((maxHours / 2).ceil() * 2).toDouble();

    if (activities.length == 1) {
      final activity = activities.first;

      return _ChartGeometry(
        points: [
          Offset(
            _leftPadding + chartWidth / 2,
            _topPadding +
                chartHeight -
                (activity.durationHours / yAxisMaximum) * chartHeight,
          ),
        ],
        yAxisMaximum: yAxisMaximum,
      );
    }

    final horizontalStep = chartWidth / (activities.length - 1);

    final points = List.generate(activities.length, (index) {
      final activity = activities[index];

      final x = _leftPadding + index * horizontalStep;
      final y =
          _topPadding +
          chartHeight -
          (activity.durationHours / yAxisMaximum) * chartHeight;

      return Offset(x, y);
    }, growable: false);

    return _ChartGeometry(points: points, yAxisMaximum: yAxisMaximum);
  }
}

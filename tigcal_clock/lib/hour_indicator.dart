import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand.dart';

/// Hour Indicator drawn with [CustomPainter]
class HourIndicator extends StatelessWidget {
  /// All of the parameters are required and must not be null.
  const HourIndicator({
    @required this.color,
    @required this.thickness,
  })  : assert(color != null),
        assert(thickness != null);

  final Color color;

  /// How thick the hand should be drawn, in logical pixels.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _IndicatorPainter(
            lineWidth: thickness,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a clock hour indicator.
class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({
    @required this.lineWidth,
    @required this.color,
  })  : assert(lineWidth != null),
        assert(color != null);

  double lineWidth;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.square;

    var innerTickRadius = center.dy - 32;
    var outerTickRadius = center.dy - 8;
    for (var tickIndex = 0; tickIndex < 12; tickIndex++) {
      var tickRot = (tickIndex * math.pi * 2 / 12);
      var innerX = math.sin(tickRot) * innerTickRadius;
      var innerY = -math.cos(tickRot) * innerTickRadius;
      var outerX = math.sin(tickRot) * outerTickRadius;
      var outerY = -math.cos(tickRot) * outerTickRadius;
      var lineStart = Offset(center.dx + innerX, center.dy + innerY);
      var lineEnd = Offset(center.dx + outerX, center.dy + outerY);
      canvas.drawLine(lineStart, lineEnd, linePaint);
    }
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) {
    return oldDelegate.lineWidth != lineWidth || oldDelegate.color != color;
  }
}

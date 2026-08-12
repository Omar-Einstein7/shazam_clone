import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A [CustomPainter] that draws the Shazam mark as animated rounded strokes.
class ShazamLogoPainter extends CustomPainter {
  /// Drawing progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double progress;

  /// The color of the logo.
  final Color color;

  /// Whether to draw a soft glow behind the strokes.
  final bool enableGlow;

  ShazamLogoPainter({
    required this.progress,
    this.color = Colors.white,
    this.enableGlow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;

    final clampedProgress = progress.clamp(0.0, 1.0);
    final upper = _buildUpperCurve();
    final lower = _buildLowerCurve();

    final gridBounds = _computeBounds([upper, lower]).inflate(9);
    final scale = math.min(
      size.width / gridBounds.width,
      size.height / gridBounds.height,
    );
    if (scale <= 0) return;

    final tx =
        (size.width - gridBounds.width * scale) / 2 - gridBounds.left * scale;
    final ty =
        (size.height - gridBounds.height * scale) / 2 - gridBounds.top * scale;

    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    final upperCurve = upper.transform(matrix.storage);
    final lowerCurve = lower.transform(matrix.storage);

    if (enableGlow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale);

      _drawAnimatedPath(canvas, upperCurve, glowPaint, clampedProgress);
      _drawAnimatedPath(canvas, lowerCurve, glowPaint, clampedProgress);
    }

    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawAnimatedPath(canvas, upperCurve, mainPaint, clampedProgress);
    _drawAnimatedPath(canvas, lowerCurve, mainPaint, clampedProgress);
  }

  /// Centerline of the upper-left chain, matching the 192x192 SVG reference.
  Path _buildUpperCurve() {
    return Path()
      ..moveTo(77.225, 23.0)
      ..lineTo(45.405, 54.82)
      ..cubicTo(28.612, 71.613, 28.612, 98.826, 45.405, 115.619)
      ..cubicTo(62.198, 132.412, 89.411, 132.412, 106.204, 115.619)
      ..lineTo(115.396, 106.427);
  }

  /// Centerline of the lower-right chain, matching the 192x192 SVG reference.
  Path _buildLowerCurve() {
    return Path()
      ..moveTo(76.604, 85.225)
      ..lineTo(85.796, 76.033)
      ..cubicTo(102.589, 59.24, 129.803, 59.24, 146.595, 76.033)
      ..cubicTo(163.388, 92.826, 163.388, 120.04, 146.595, 136.832)
      ..lineTo(114.775, 168.652);
  }

  /// Draws a partial [path] based on [progress] using [PathMetrics].
  void _drawAnimatedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    for (final metric in path.computeMetrics()) {
      final end = metric.length * progress;
      if (end > 0) {
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  /// Tight bounds of the given paths, used to center the drawing.
  Rect _computeBounds(List<Path> paths) {
    Rect? bounds;
    for (final path in paths) {
      for (final metric in path.computeMetrics()) {
        for (var i = 0; i <= 64; i++) {
          final position = metric
              .getTangentForOffset(metric.length * i / 64)
              ?.position;
          if (position == null) continue;
          bounds = bounds == null
              ? Rect.fromPoints(position, position)
              : bounds.expandToInclude(Rect.fromPoints(position, position));
        }
      }
    }
    return bounds ?? Rect.zero;
  }

  @override
  bool shouldRepaint(ShazamLogoPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.enableGlow != enableGlow;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A [CustomPainter] that draws the exact Shazam logo from SVG.
class ShazamLogoPainter extends CustomPainter {
  /// Drawing progress from 0.0 (nothing drawn) to 1.0 (fully drawn).
  final double progress;

  /// The color of the logo.
  final Color color;

  /// Whether to draw a soft glow behind the strokes.
  final bool enableGlow;

  /// Vertical shift of the top half downward (in the original 192px grid).
  final double upperOffsetY;

  /// Horizontal shift of the top half to the right (in the original 192px grid).
  final double upperOffsetX;

  ShazamLogoPainter({
    required this.progress,
    this.color = Colors.white,
    this.enableGlow = true,
    this.upperOffsetY = 25.0, // move the top half downward
    this.upperOffsetX = 30.0, // move the top half slightly right
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;

    final clampedProgress = progress.clamp(0.0, 1.0);

    // Build the curves on the original (192x192) grid, applying the offset.
    final upper = _buildUpperCurve().shift(
      Offset(upperOffsetX, upperOffsetY),
    );
    final lower = _buildLowerCurve();

    // Drawing bounds on the grid + margin for stroke width and glow (grid units).
    const gridMargin = 26.0;
    final gridBounds = _computeBounds([upper, lower]);
    final gridW = gridBounds.width + (gridMargin * 2);
    final gridH = gridBounds.height + (gridMargin * 2);

    // Largest fit-without-crop scale that preserves shape at any aspect ratio.
    final scale = math.min(size.width / gridW, size.height / gridH);
    if (scale <= 0) return;

    final tx = (size.width - gridW * scale) / 2 -
        (gridBounds.left - gridMargin) * scale;
    final ty = (size.height - gridH * scale) / 2 -
        (gridBounds.top - gridMargin) * scale;

    // Scale first, then translate to center the drawing.
    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    final upperCurve = upper.transform(matrix.storage);
    final lowerCurve = lower.transform(matrix.storage);

    // ── Glow layer (drawn first, behind the main strokes) ──
    if (enableGlow && clampedProgress > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * scale);

      _drawAnimatedPath(canvas, upperCurve, glowPaint, clampedProgress);
      _drawAnimatedPath(canvas, lowerCurve, glowPaint, clampedProgress);
    }

    // ── Main strokes / Paths ──
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawAnimatedPath(canvas, upperCurve, mainPaint, clampedProgress);
    _drawAnimatedPath(canvas, lowerCurve, mainPaint, clampedProgress);
  }

  /// Upper/left half taken from the SVG.
  Path _buildUpperCurve() {
    return Path()
      ..moveTo(98.356, 91.134)
      ..lineTo(89.163, 100.327)
      ..cubicTo(74.713, 114.777, 51.287, 114.777, 36.837, 100.327)
      ..cubicTo(22.387, 85.877, 22.387, 62.451, 36.837, 48.001)
      ..lineTo(68.657, 16.181);
  }

  /// Lower/right half taken from the SVG.
  Path _buildLowerCurve() {
    return Path()
      ..moveTo(93.644, 100.866)
      ..lineTo(102.836, 91.673)
      ..cubicTo(117.286, 77.224, 140.713, 77.224, 155.162, 91.673)
      ..cubicTo(169.612, 106.123, 169.612, 129.549, 155.162, 143.999)
      ..lineTo(123.342, 175.819);
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
          final position =
              metric.getTangentForOffset(metric.length * i / 64)?.position;
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
      oldDelegate.enableGlow != enableGlow ||
      oldDelegate.upperOffsetY != upperOffsetY ||
      oldDelegate.upperOffsetX != upperOffsetX;
}
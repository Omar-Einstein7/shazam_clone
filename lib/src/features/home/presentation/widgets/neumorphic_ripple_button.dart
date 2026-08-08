import 'package:flutter/material.dart';
import 'package:flutter_complete_project/src/imports/packages_imports.dart';

/// Neumorphic circular button that emits a soft "splash" ripple (staggered
/// light/dark rings, like the pressed-in depth of the surface).
///
/// While [rippling] is `true` the waves keep looping (used for the full
/// listening window); tapping produces a short press-in feedback.
class NeumorphicRippleButton extends StatefulWidget {
  const NeumorphicRippleButton({
    super.key,
    this.diameter = 120,
    this.assetPath = 'assets/icons/shazam-svgrepo-com.svg',
    this.assetSize = 56,
    this.rippling = false,
    this.onTap,
  });

  /// Button diameter in logical pixels.
  final double diameter;

  /// Center SVG asset (the "Shazam" logo, tinted white).
  final String assetPath;
  final double assetSize;

  /// When true, continuously emits the three splash waves.
  final bool rippling;

  final VoidCallback? onTap;

  @override
  State<NeumorphicRippleButton> createState() => _NeumorphicRippleButtonState();
}

class _NeumorphicRippleButtonState extends State<NeumorphicRippleButton>
    with TickerProviderStateMixin {
  /// Single driver for the three staggered splash ripples.
  late final AnimationController _rippleController;

  /// Drives the neumorphic press-in (scale down + shadow collapse).
  late final AnimationController _pressController;

  late final Animation<double> _pressScale;

  static const List<BoxShadow> _restShadows = [
    BoxShadow(
      color: Color(0x66FFFFFF),
      blurRadius: 20,
      offset: Offset(-12, -12),
    ),
    BoxShadow(
      color: Color(0x661000E0),
      blurRadius: 20,
      offset: Offset(12, 12),
    ),
  ];

  static const List<BoxShadow> _pressedShadows = [
    BoxShadow(
      color: Color(0x66FFFFFF),
      blurRadius: 6,
      offset: Offset(-4, -4),
    ),
    BoxShadow(
      color: Color(0x661000E0),
      blurRadius: 6,
      offset: Offset(4, 4),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    if (widget.rippling) _rippleController.repeat();
  }

  @override
  void didUpdateWidget(covariant NeumorphicRippleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rippling == oldWidget.rippling) return;

    if (widget.rippling) {
      _rippleController.repeat();
    } else {
      _rippleController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _pressController.forward().whenComplete(() {
      if (mounted) _pressController.reverse();
    });
  }

  double _ripple(int index) {
    final start = index * 0.35;
    final p = (_rippleController.value - start) / (1.0 - start);
    return p.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final rippleBox = Size.square(widget.diameter * 2.2);

    return SizedBox.fromSize(
      size: rippleBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Splash ripples (concentric around the button) ──
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, _) {
              return CustomPaint(
                size: rippleBox,
                painter: _NeumorphicRipplePainter(
                  centre: rippleBox.center(Offset.zero),
                  maxRadius: rippleBox.shortestSide / 2 - 12,
                  progress1: _ripple(0),
                  progress2: _ripple(1),
                  progress3: _ripple(2),
                ),
              );
            },
          ),
          // ── Neumorphic button ──
          AnimatedBuilder(
            animation: _pressController,
            builder: (context, _) {
              return Transform.scale(
                scale: _pressScale.value,
                child: Semantics(
                  button: true,
                  label: 'Shazam button',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _pressController.forward(),
                    onTapCancel: () => _pressController.reverse(),
                    onTapUp: (_) => _pressController.reverse(),
                    onTap: _handleTap,
                    child: Container(
                      width: widget.diameter,
                      height: widget.diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF006AFF),
                        boxShadow: _pressController.isAnimating
                            ? _pressedShadows
                            : _restShadows,
                      ),
                      child: SvgPicture.asset(
                        widget.assetPath,
                        width: widget.assetSize,
                        height: widget.assetSize,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Painter that draws three staggered sonar-style waves: a soft radial glow
/// that swells outward with a neumorphic light/dark edge ring.
class _NeumorphicRipplePainter extends CustomPainter {
  _NeumorphicRipplePainter({
    required this.centre,
    required this.maxRadius,
    required this.progress1,
    required this.progress2,
    required this.progress3,
  });

  final Offset centre;
  final double maxRadius;
  final double progress1;
  final double progress2;
  final double progress3;

  @override
  void paint(Canvas canvas, Size size) {
    for (final progress in [progress1, progress2, progress3]) {
      if (progress <= 0.01 || progress >= 1.0) continue;

      final eased = Curves.easeOutCubic.transform(progress);
      final radius = maxRadius * eased;
      final fade = (1.0 - eased);
      final strokeWidth = 2.5 + (4.0 * fade);

      final bounds = Rect.fromCircle(center: centre, radius: radius);

      // Soft expanding glow (sonar pulse)
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF6FB8FF).withValues(alpha: 0.45 * fade),
            const Color(0xFF6FB8FF).withValues(alpha: 0.0),
          ],
        ).createShader(bounds);
      canvas.drawCircle(centre, radius, glow);

      // Dark bottom-right edge (neumorphic depth)
      final shadow = Paint()
        ..color = const Color(0xFF0030C8).withValues(alpha: 0.85 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(centre.translate(4, 4), radius, shadow);

      // Light top-left edge
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.35 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(centre.translate(-4, -4), radius, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _NeumorphicRipplePainter oldDelegate) {
    return oldDelegate.progress1 != progress1 ||
        oldDelegate.progress2 != progress2 ||
        oldDelegate.progress3 != progress3;
  }
}
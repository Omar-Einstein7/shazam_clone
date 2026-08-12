import 'package:flutter_complete_project/src/features/splash/presentation/widgets/shazam_logo_painter.dart';
import 'package:flutter_complete_project/src/imports/core_imports.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Controls the stroke-drawing animation of the Shazam logo.
  late final AnimationController _drawController;

  /// Controls a subtle pulse/glow after the logo finishes drawing.
  late final AnimationController _pulseController;

  /// Controls the single fade-out at the end of the splash transition.
  late final AnimationController _fadeController;

  /// Curved animation for the stroke-drawing progress.
  late final Animation<double> _drawAnimation;

  /// Curved animation for the pulse scale effect.
  late final Animation<double> _pulseAnimation;

  /// Fade-out for the entire logo container.
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ── Draw animation: traces the logo strokes over 1.8 seconds ──
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _drawController.value = 1.0;

    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: AppCurves.emphasized,
    );

    // ── Pulse animation: subtle breathe after drawing completes ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Start full, erase the logo, redraw it, then pulse and navigate.
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Small delay so the gradient background renders first
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // 1) Reverse the drawing so the static logo disappears along its path.
    await _drawController.reverse();
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    // 2) Redraw the logo using the original creation transition.
    await _drawController.forward();
    if (!mounted) return;

    // 3) After drawing completes, start a gentle pulse.
    _pulseController.repeat(reverse: true);

    // 4) Let the logo settle, then hand over to Home. The splash circle is
    //    visually identical to the Home neumorphic button, so the 450ms
    //    cross-fade below reads as "nothing happened".
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // Settle the pulse back to scale 1.0 so it matches Home's resting button.
    _pulseController
      ..stop()
      ..value = 0;

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = 160.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF008EFF),
                  Color(0xFF006AFF),
                  Color(0xFF004EFF),
                ],
              ),
            ),
          ),

          // ── Animated Shazam logo ──
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _drawController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  final scale = _pulseController.isAnimating
                      ? _pulseAnimation.value
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Hero(
                      tag: AppHeroes.listenerOrb,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ── Neumorphic circular surface (same look as the
                          //    Home button so the morph is seamless) ──
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF006AFF),
                              boxShadow: const [
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
                              ],
                            ),
                          ),
                          CustomPaint(
                            size: Size(logoSize * 0.55, logoSize * 0.55),
                            painter: ShazamLogoPainter(
                              progress: _drawAnimation.value,
                              color: Colors.white,
                              enableGlow: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

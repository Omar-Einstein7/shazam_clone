import 'package:flutter/material.dart';

/// A single reusable neumorphic "surface" used across the app.
///
/// Neumorphism works by pairing a raised object with a light shadow
/// (top-left) and a dark shadow (bottom-right) on a flat monochromatic
/// background. When placed on a gradient (e.g. the blue home gradient), pass
/// a semi-transparent [color] plus tinted [shadowLight]/[shadowDark] so the
/// background bleeds through and the soft 3D effect stays readable.
/// Pass [raised] = false for a "pressed/inset" look.
class NeumorphicBox extends StatelessWidget {
  const NeumorphicBox({
    super.key,
    required this.child,
    this.raised = true,
    this.radius = 16,
    this.padding,
    this.color,
    this.borderColor,
    this.shadowLight,
    this.shadowDark,
    this.gradient,
  });

  final Widget child;
  final bool raised;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final Color? shadowLight;
  final Color? shadowDark;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final base = color ?? const Color(0xFF14142E);
    final light = shadowLight ?? const Color(0xFF2E2E5E);
    final dark = shadowDark ?? const Color(0xFF05050F);

    const darkOffset = Offset(6, 6);
    const lightOffset = Offset(-6, -6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(base, Colors.white, raised ? 0.05 : 0.0)!,
                Color.lerp(base, Colors.black, raised ? 0.06 : 0.0)!,
              ],
            ),
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
        boxShadow: raised
            ? [
                BoxShadow(
                    color: light, offset: lightOffset, blurRadius: 18),
                BoxShadow(
                    color: dark, offset: darkOffset, blurRadius: 18),
              ]
            : [
                BoxShadow(
                    color: light,
                    offset: -darkOffset,
                    blurRadius: 12,
                    spreadRadius: 1),
                BoxShadow(
                    color: dark,
                    offset: -lightOffset,
                    blurRadius: 12,
                    spreadRadius: 1),
              ],
      ),
      child: child,
    );
  }
}

/// A neumorphic circular surface (used for the artwork and the play button).
class NeumorphicCircle extends StatelessWidget {
  const NeumorphicCircle({
    super.key,
    required this.child,
    this.size,
    this.raised = true,
    this.color,
    this.shadowLight,
    this.shadowDark,
  });

  final Widget child;
  final double? size;
  final bool raised;
  final Color? color;
  final Color? shadowLight;
  final Color? shadowDark;

  @override
  Widget build(BuildContext context) {
    final base = color ?? const Color(0xFF14142A);
    final light = shadowLight ?? const Color(0xFF2E2E5E);
    final dark = shadowDark ?? const Color(0xFF05050F);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(base, Colors.white, raised ? 0.08 : 0.0)!,
            Color.lerp(base, Colors.black, raised ? 0.08 : 0.0)!,
          ],
        ),
        boxShadow: raised
            ? [
                BoxShadow(
                    color: light,
                    offset: const Offset(-7, -7),
                    blurRadius: 22),
                BoxShadow(
                    color: dark,
                    offset: const Offset(7, 7),
                    blurRadius: 22),
              ]
            : [
                BoxShadow(
                    color: light,
                    offset: const Offset(-7, -7),
                    blurRadius: 14,
                    spreadRadius: 1),
                BoxShadow(
                    color: dark,
                    offset: const Offset(7, 7),
                    blurRadius: 14,
                    spreadRadius: 1),
              ],
      ),
      child: child,
    );
  }
}
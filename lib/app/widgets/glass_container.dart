import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Reusable glass morphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final BoxShadow? shadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.color,
    this.gradient,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: isDark 
            ? GlassColors.darkGlassBorder 
            : GlassColors.lightGlassBorder,
          width: 1.5,
        ),
        boxShadow: [
          shadow ?? BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? (isDark 
                ? GlassColors.darkGradient 
                : GlassColors.lightGradient),
              color: color,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


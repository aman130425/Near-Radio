import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Glass morphism card widget for station items
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: GlassContainer(
          padding: padding ?? const EdgeInsets.all(16),
          margin: margin ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          borderRadius: borderRadius,
          blur: blur,
          border: border,
          child: child,
        ),
      ),
    );
  }
}


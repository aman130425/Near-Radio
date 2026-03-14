import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Glass morphism button widget
class GlassButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const GlassButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.borderRadius = 15.0,
    this.blur = 10.0,
    this.padding,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black87;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark 
                ? GlassColors.darkGlassBorder 
                : GlassColors.lightGlassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark 
                    ? GlassColors.darkGradient 
                    : GlassColors.lightGradient,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      if (text != null) const SizedBox(width: 8),
                    ],
                    if (text != null)
                      Text(
                        text!,
                        style: TextStyle(
                          color: textColor ?? defaultTextColor,
                          fontSize: fontSize ?? 16,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../../core/constants/app_strings.dart';

/// Glass morphism bottom navigation bar
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: isDark 
                ? GlassColors.darkGradient 
                : GlassColors.lightGradient,
              border: Border.all(
                color: isDark 
                  ? GlassColors.darkGlassBorder 
                  : GlassColors.lightGlassBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_rounded,
                  label: AppStrings.home,
                  index: 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.radio_rounded,
                  label: AppStrings.radio,
                  index: 1,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.podcasts_rounded,
                  label: AppStrings.podcast,
                  index: 2,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.music_note_rounded,
                  label: AppStrings.local,
                  index: 3,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.favorite_rounded,
                  label: AppStrings.favourites,
                  index: 4,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : (isDark ? Colors.white70 : Colors.black54);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


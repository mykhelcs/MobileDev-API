import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Frosted glass bottom navigation bar (68px tall).
class MovieHubBottomNavBar extends StatelessWidget {
  const MovieHubBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_rounded,         label: 'Home'),
    (icon: Icons.search_rounded,        label: 'Discover'),
    (icon: Icons.bookmark_rounded,      label: 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surface1.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(color: AppColors.border2, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isActive ? AppColors.accent : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: AppTypography.navLabel.copyWith(
                            color: isActive ? AppColors.accent : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: isActive ? 20 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

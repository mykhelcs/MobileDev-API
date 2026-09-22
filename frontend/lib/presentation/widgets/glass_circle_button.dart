import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A frosted-glass circular icon button (back, heart, add-to-list).
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
    this.backgroundColor = const Color(0x26FFFFFF),
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// A shimmer-animated loading skeleton box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a movie poster card (110x165).
class MoviePosterSkeleton extends StatelessWidget {
  const MoviePosterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 110, height: 165, borderRadius: 10),
        SizedBox(height: 6),
        ShimmerBox(width: 90, height: 12),
        SizedBox(height: 4),
        ShimmerBox(width: 60, height: 10),
      ],
    );
  }
}

/// Shimmer skeleton for a wide now-playing card (220x130).
class NowPlayingSkeleton extends StatelessWidget {
  const NowPlayingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 220, height: 130, borderRadius: 14),
        SizedBox(height: 6),
        ShimmerBox(width: 160, height: 12),
      ],
    );
  }
}

/// Shimmer skeleton for the hero section (full-width, 480px).
class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface1,
      highlightColor: AppColors.surface2,
      child: Container(
        height: 480,
        color: AppColors.surface1,
      ),
    );
  }
}

/// 3-column grid skeleton for search results.
class SearchGridSkeleton extends StatelessWidget {
  const SearchGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2 / 3,
      ),
      itemCount: 9,
      itemBuilder: (_, __) => const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 10),
    );
  }
}

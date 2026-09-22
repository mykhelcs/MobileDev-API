import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'shimmer_skeleton.dart';

/// Trending poster card: 110x165 with rank badge and rating badge.
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.rank,
    required this.onTap,
  });

  final Movie movie;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    width: 110,
                    height: 165,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(width: 110, height: 165),
                    errorWidget: (_, __, ___) => Container(
                      width: 110,
                      height: 165,
                      color: AppColors.surface2,
                      child: const Icon(Icons.movie, color: AppColors.textMuted2, size: 32),
                    ),
                  ),
                ),
                // Rank badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$rank',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(movie.ratingFormatted, style: AppTypography.rating.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              movie.title,
              style: AppTypography.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(movie.releaseYear, style: AppTypography.labelSmall),
          ],
        ),
      ),
    );
  }
}

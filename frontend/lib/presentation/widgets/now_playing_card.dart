import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import 'shimmer_skeleton.dart';

/// Wide now-playing card: 220px width, landscape backdrop.
class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  final Movie movie;
  final VoidCallback onTap;

  String _genreName(int id) {
    try {
      return AppConstants.genres.firstWhere((g) => g.id == id).name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreLabel = movie.genreIds.isNotEmpty ? _genreName(movie.genreIds.first) : '';
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    width: 220,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(width: 220, height: 130, borderRadius: 14),
                    errorWidget: (_, __, ___) => Container(
                      width: 220, height: 130,
                      color: AppColors.surface2,
                      child: const Icon(Icons.image_not_supported, color: AppColors.textMuted2),
                    ),
                  ),
                ),
                // Bottom gradient
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(movie.ratingFormatted, style: AppTypography.rating),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(movie.title, style: AppTypography.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            if (genreLabel.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Text(genreLabel, style: AppTypography.chip.copyWith(fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import 'shimmer_skeleton.dart';

/// Horizontal list tile for the Favorites screen.
class FavItemTile extends StatelessWidget {
  const FavItemTile({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onDelete,
  });

  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _genreName(int id) {
    try {
      return AppConstants.genres.firstWhere((g) => g.id == id).name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 70,
                height: 105,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerBox(width: 70, height: 105, borderRadius: 8),
                errorWidget: (_, __, ___) => Container(
                  width: 70, height: 105,
                  color: AppColors.surface2,
                  child: const Icon(Icons.movie, color: AppColors.textMuted2, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Middle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: AppTypography.detailTitle.copyWith(fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(movie.ratingFormatted, style: AppTypography.rating),
                      const SizedBox(width: 8),
                      Text('\u2022 ${movie.releaseYear}', style: AppTypography.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: movie.genreIds.take(3).map((id) {
                      final name = _genreName(id);
                      if (name.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border2),
                        ),
                        child: Text(name, style: AppTypography.chip.copyWith(fontSize: 10)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.heartRedDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.heartRed.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.delete_outline, size: 18, color: AppColors.heartRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

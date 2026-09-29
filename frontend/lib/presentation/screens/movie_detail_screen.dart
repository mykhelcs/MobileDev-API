import 'package:flutter/material.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen displaying the complete movie details retrieved from the TMDB API.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          movie.title,
          style: AppTypography.cardTitle.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface1,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop / Poster Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surface2,
                    child: const Center(
                      child: Icon(Icons.movie, size: 64, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Tagline
            Text(
              movie.title,
              style: AppTypography.detailTitle,
            ),
            if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                movie.tagline!,
                style: AppTypography.tagline,
              ),
            ],
            const SizedBox(height: 16),

            // Metadata Chips (Rating, Release Date, Runtime, Status)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.star_rounded,
                  label: '${movie.ratingFormatted} / 10',
                  color: AppColors.gold,
                ),
                _buildInfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: movie.releaseDate.isNotEmpty ? movie.releaseDate : movie.releaseYear,
                ),
                if (movie.runtime != null && movie.runtime! > 0)
                  _buildInfoChip(
                    icon: Icons.schedule_rounded,
                    label: movie.runtimeFormatted,
                  ),
                if (movie.status != null && movie.status!.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.info_outline_rounded,
                    label: movie.status!,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Overview Section
            Text(
              'Overview',
              style: AppTypography.sectionHeadline,
            ),
            const SizedBox(height: 8),
            Text(
              movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
              style: AppTypography.bodyText,
            ),
            const SizedBox(height: 24),

            // API Output Inspector Card (demonstrates raw parsed API fields)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.data_object, size: 20, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'TMDB API Output Data',
                        style: AppTypography.cardTitle.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 20),
                  _buildApiFieldRow('ID', movie.id.toString()),
                  _buildApiFieldRow('Title', movie.title),
                  _buildApiFieldRow('Vote Average', movie.voteAverage.toString()),
                  _buildApiFieldRow('Release Date', movie.releaseDate),
                  _buildApiFieldRow('Poster Path', movie.posterPath ?? 'null'),
                  _buildApiFieldRow('Backdrop Path', movie.backdropPath ?? 'null'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiFieldRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$key:',
              style: AppTypography.metaText.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyText.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

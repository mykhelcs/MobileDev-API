import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';

/// ============================================================================
/// SCREEN: MovieListScreen
/// ============================================================================
/// The primary landing screen of the app. It displays movies retrieved from the
/// TMDB API and allows the user to:
/// 1. Browse movies in a scrollable list.
/// 2. Tap any movie card to navigate to its detail view.
/// 3. Pull-down to refresh the list or tap the reload icon in the AppBar.
/// 4. View clear feedback during loading, error, or empty states.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  @override
  void initState() {
    super.initState();

    // In Flutter, widget initialization happens before the first frame is painted.
    // We schedule data fetching using addPostFrameCallback so that provider
    // notifications do not conflict with the initial build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      if (provider.movies.isEmpty && !provider.isLoading) {
        provider.loadMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MovieHub — Your Movie Companion',
          style: AppTypography.cardTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: AppColors.surface1,
        elevation: 0,
        actions: [
          // Quick reload button in the top app bar
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            tooltip: 'Reload from API',
            onPressed: () => context.read<MovieProvider>().loadMovies(),
          ),
        ],
      ),
      // Consumer listens for changes from MovieProvider and rebuilds only this subtree
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          // State 1: Initial Loading Indicator
          if (provider.isLoading && provider.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text(
                    'Fetching movies via Dio...',
                    style: AppTypography.metaText,
                  ),
                ],
              ),
            );
          }

          // State 2: Error Feedback Screen with retry button
          if (provider.errorMessage != null && provider.movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.heartRed),
                    const SizedBox(height: 16),
                    Text(
                      'API Connection Error',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyText.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      onPressed: () => provider.loadMovies(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: Empty State (API returned 0 items)
          if (provider.movies.isEmpty) {
            return Center(
              child: Text(
                'No movies found.',
                style: AppTypography.metaText,
              ),
            );
          }

          // State 4: Populated List with Pull-to-Refresh support
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface1,
            onRefresh: () => provider.loadMovies(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.movies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = provider.movies[index];
                return _MovieCard(
                  movie: movie,
                  onTap: () {
                    // Update provider selection and navigate to detail page
                    provider.selectMovie(movie);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
/// COMPONENT WIDGET: _MovieCard
/// ============================================================================
/// Reusable card displaying an individual movie item:
/// - Poster image thumbnail
/// - Title with 2-line overflow cutoff
/// - Star rating and calendar year badge
/// - Brief synopsis overview
class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
    required this.onTap,
  });

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster thumbnail with network error fallback
            SizedBox(
              width: 100,
              height: 150,
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  child: const Center(
                    child: Icon(Icons.movie, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            // Movie info metadata
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          movie.ratingFormatted,
                          style: AppTypography.rating,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          movie.releaseYear,
                          style: AppTypography.metaText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyText.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

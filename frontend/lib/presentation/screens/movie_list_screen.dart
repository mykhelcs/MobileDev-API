import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/movie_provider.dart';
import 'movie_detail_screen.dart';

/// ============================================================================
/// SCREEN: MovieListScreen
/// ============================================================================
/// The primary landing screen of the app. It provides:
/// 1. Keyword search bar hooked up to TMDB `/search/movie` API endpoint.
/// 2. Category feed selector: Popular, Top Rated, and Trending TMDB endpoints.
/// 3. Populated movie cards with poster, rating, release year, and synopsis.
/// 4. Asynchronous state indicators for loading, errors, and empty states.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController? _searchController;
  TextEditingController get _controller => _searchController ??= TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      if (provider.movies.isEmpty && !provider.isLoading) {
        provider.loadMovies();
      }
    });
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
            tooltip: 'Reload from API',
            onPressed: () {
              final provider = context.read<MovieProvider>();
              if (provider.isSearchActive) {
                provider.search(provider.searchQuery);
              } else {
                provider.loadCategoryMovies(provider.activeCategory);
              }
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Search & Filter Controls Bar ───────────────────────────────
              Container(
                color: AppColors.surface1,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search Input Field
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search movies (e.g. Inception, Avatar)...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                                onPressed: () {
                                  _controller.clear();
                                  provider.clearSearch();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) {
                        setState(() {}); // updates suffix icon visibility
                        provider.search(val);
                      },
                      onSubmitted: (val) {
                        provider.search(val);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Filter Chips (Hidden when actively searching)
                    if (!provider.isSearchActive)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: MovieCategory.values.map((cat) {
                            final isSelected = provider.activeCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(cat.chipLabel),
                                selected: isSelected,
                                onSelected: (_) => provider.switchCategory(cat),
                                selectedColor: AppColors.accent,
                                backgroundColor: AppColors.surface2,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppColors.accentGlow : AppColors.border,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      // Search Indicator Row
                      Row(
                        children: [
                          const Icon(Icons.travel_explore_rounded, size: 16, color: AppColors.textPurpleDim),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Results for "${provider.searchQuery}" (${provider.searchResults.length} found)',
                              style: AppTypography.metaText.copyWith(color: AppColors.textPurpleDim),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _controller.clear();
                              provider.clearSearch();
                            },
                            child: const Text('Back to feeds', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // ── Main Content Area (Feed vs Search Results) ─────────────────
              Expanded(
                child: provider.isSearchActive
                    ? _buildSearchResults(provider)
                    : _buildCategoryFeed(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Category Feed Content ──────────────────────────────────────────────────
  Widget _buildCategoryFeed(MovieProvider provider) {
    if (provider.isLoading && provider.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Fetching ${provider.activeCategory.label} movies via Dio...', style: AppTypography.metaText),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.movies.isEmpty) {
      return _buildErrorState(
        message: provider.errorMessage!,
        onRetry: () => provider.loadCategoryMovies(provider.activeCategory),
      );
    }

    if (provider.movies.isEmpty) {
      return Center(
        child: Text('No movies found.', style: AppTypography.metaText),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface1,
      onRefresh: () => provider.loadCategoryMovies(provider.activeCategory),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: provider.movies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final movie = provider.movies[index];
          return _MovieCard(
            movie: movie,
            onTap: () => _openMovieDetail(context, movie),
          );
        },
      ),
    );
  }

  // ── Search Results Content ─────────────────────────────────────────────────
  Widget _buildSearchResults(MovieProvider provider) {
    if (provider.isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Searching TMDB API...', style: AppTypography.metaText),
          ],
        ),
      );
    }

    if (provider.searchErrorMessage != null) {
      return _buildErrorState(
        message: provider.searchErrorMessage!,
        onRetry: () => provider.search(provider.searchQuery),
      );
    }

    if (provider.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'No movies matched "${provider.searchQuery}"',
                style: AppTypography.cardTitle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching for another movie title.',
                style: AppTypography.metaText,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = provider.searchResults[index];
        return _MovieCard(
          movie: movie,
          onTap: () => _openMovieDetail(context, movie),
        );
      },
    );
  }

  void _openMovieDetail(BuildContext context, Movie movie) {
    context.read<MovieProvider>().selectMovie(movie);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  Widget _buildErrorState({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.heartRed),
            const SizedBox(height: 16),
            Text('API Connection Error', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: AppTypography.bodyText.copyWith(fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// COMPONENT WIDGET: _MovieCard
/// ============================================================================
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
                        Text(movie.ratingFormatted, style: AppTypography.rating),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(movie.releaseYear, style: AppTypography.metaText),
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

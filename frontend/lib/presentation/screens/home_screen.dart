import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/movie.dart';
import '../providers/home_provider.dart';
import '../widgets/movie_poster_card.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/search_movie_card.dart';
import '../widgets/glass_circle_button.dart';
import '../widgets/shimmer_skeleton.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadInitial();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        context.read<HomeProvider>().loadMorePopular();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(movieId: movieId),
      ),
    );
  }

  String _genreName(int id) {
    try {
      return AppConstants.genres.firstWhere((g) => g.id == id).name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    if (provider.status == HomeStatus.loading) {
      return const SingleChildScrollView(
        child: Column(
          children: [
            HeroSkeleton(),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  MoviePosterSkeleton(),
                  SizedBox(width: 12),
                  MoviePosterSkeleton(),
                  SizedBox(width: 12),
                  MoviePosterSkeleton(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (provider.status == HomeStatus.error) {
      return ErrorView(
        message: provider.errorMessage ?? 'An error occurred while loading movies.',
        onRetry: () => provider.loadInitial(),
      );
    }

    final heroMovie = provider.heroMovie;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface1,
        onRefresh: () => provider.loadInitial(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Hero Section ───────────────────────────────────────────
              if (heroMovie != null) _buildHero(context, heroMovie),

              const SizedBox(height: 28),

              // ── 2. Trending Section ───────────────────────────────────────
              _buildSectionHeader(context, title: 'Trending This Week'),
              const SizedBox(height: 14),
              SizedBox(
                height: 235,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.trending.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final movie = provider.trending[index];
                    return MoviePosterCard(
                      movie: movie,
                      rank: index + 1,
                      onTap: () => _navigateToDetail(context, movie.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── 3. Now Playing Section ────────────────────────────────────
              _buildSectionHeader(context, title: 'Now Playing in Theaters'),
              const SizedBox(height: 14),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.nowPlaying.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final movie = provider.nowPlaying[index];
                    return NowPlayingCard(
                      movie: movie,
                      onTap: () => _navigateToDetail(context, movie.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── 4. Popular Movies Infinite Grid ───────────────────────────
              _buildSectionHeader(context, title: 'Popular Movies'),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: provider.popular.length,
                  itemBuilder: (context, index) {
                    final movie = provider.popular[index];
                    return SearchMovieCard(
                      movie: movie,
                      onTap: () => _navigateToDetail(context, movie.id),
                    );
                  },
                ),
              ),

              if (provider.loadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, Movie movie) {
    return Stack(
      children: [
        // Backdrop Image
        CachedNetworkImage(
          imageUrl: movie.backdropUrl,
          height: 480,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ShimmerBox(width: double.infinity, height: 480, borderRadius: 0),
          errorWidget: (_, __, ___) => Container(height: 480, color: AppColors.surface1),
        ),

        // Gradient Overlay
        Container(
          height: 480,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                AppColors.background.withValues(alpha: 0.8),
                AppColors.background,
              ],
              stops: const [0.0, 0.3, 0.75, 1.0],
            ),
          ),
        ),

        // Hero Content
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genre Badges
              Wrap(
                spacing: 8,
                children: movie.genreIds.take(2).map((id) {
                  final name = _genreName(id);
                  if (name.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                    ),
                    child: Text(name, style: AppTypography.chip),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                movie.title,
                style: AppTypography.heroTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Meta row
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(movie.ratingFormatted, style: AppTypography.rating),
                  const SizedBox(width: 8),
                  Text('\u2022', style: AppTypography.metaText),
                  const SizedBox(width: 8),
                  Text(movie.releaseYear, style: AppTypography.metaText),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToDetail(context, movie.id),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text('Watch now', style: AppTypography.buttonLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: AppColors.accentGlow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassCircleButton(
                    icon: Icons.bookmark_border_rounded,
                    size: 48,
                    iconSize: 22,
                    onTap: () => _navigateToDetail(context, movie.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(title, style: AppTypography.sectionHeadline),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/movie.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/tmdb_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/detail_provider.dart';
import '../widgets/glass_circle_button.dart';
import '../widgets/shimmer_skeleton.dart';
import '../widgets/state_views.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DetailProvider(
        api: ctx.read<TmdbApiService>(),
        favoritesService: ctx.read<FavoritesService>(),
      )..loadDetail(movieId),
      child: const _DetailScreenContent(),
    );
  }
}

class _DetailScreenContent extends StatelessWidget {
  const _DetailScreenContent();

  String _genreName(int id) {
    try {
      return AppConstants.genres.firstWhere((g) => g.id == id).name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetailProvider>();

    if (provider.status == DetailStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (provider.status == DetailStatus.error || provider.movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: provider.errorMessage ?? 'Could not load details',
          onRetry: () => provider.loadDetail(provider.movie?.id ?? 0),
        ),
      );
    }

    final movie = provider.movie!;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Hero Backdrop + Poster Overlap ──────────────────────
                _buildBackdropHeader(context, movie, provider),

                const SizedBox(height: 60),

                // ── 2. Title & Tagline ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: AppTypography.detailTitle),
                      if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(movie.tagline!, style: AppTypography.tagline),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── 3. Stats Pill Bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildStatsBar(movie),
                ),

                const SizedBox(height: 16),

                // ── 4. Genre Chips ─────────────────────────────────────────
                if (movie.genreIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genreIds.map((id) {
                        final name = _genreName(id);
                        if (name.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border2),
                          ),
                          child: Text(name, style: AppTypography.chip),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),

                // ── 5. Overview ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview', style: AppTypography.sectionHeadline.copyWith(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(movie.overview, style: AppTypography.bodyText),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── 6. Cast Members ────────────────────────────────────────
                if (provider.cast.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Top Cast', style: AppTypography.sectionHeadline.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.cast.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final cast = provider.cast[index];
                        return SizedBox(
                          width: 64,
                          child: Column(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: cast.profileUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const ShimmerBox(width: 56, height: 56, borderRadius: 28),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.surface2,
                                    child: const Icon(Icons.person, color: AppColors.textMuted2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cast.name,
                                style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                cast.character,
                                style: AppTypography.labelSmall.copyWith(fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── 7. Where to Watch ──────────────────────────────────────
                if (provider.watchProviders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Where to Watch', style: AppTypography.sectionHeadline.copyWith(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.watchProviders.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final p = provider.watchProviders[index];
                        return Tooltip(
                          message: p.providerName,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: p.logoUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 90), // Space for sticky bottom button
              ],
            ),
          ),

          // ── Sticky Bottom CTA ──────────────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: () async {
                final query = Uri.encodeComponent('${movie.title} trailer');
                final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
              label: Text('Watch Trailer', style: AppTypography.buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.accentGlow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropHeader(BuildContext context, Movie movie, DetailProvider provider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Backdrop
        CachedNetworkImage(
          imageUrl: movie.backdropUrl,
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ShimmerBox(width: double.infinity, height: 320, borderRadius: 0),
          errorWidget: (_, __, ___) => Container(height: 320, color: AppColors.surface1),
        ),

        // Gradient
        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
                AppColors.background,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Top Navigation buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassCircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                GlassCircleButton(
                  icon: provider.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  iconColor: provider.isFavorite ? AppColors.accent : AppColors.textPrimary,
                  onTap: () => provider.toggleFavorite(),
                ),
              ],
            ),
          ),
        ),

        // Floating Poster overlapping the header bottom
        Positioned(
          bottom: -45,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 104,
                height: 156,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerBox(width: 104, height: 156),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(Movie movie) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCol('RATING', '★ ${movie.ratingFormatted}', AppColors.gold),
          _divider(),
          _buildStatCol('RUNTIME', movie.runtimeFormatted, AppColors.textPrimary),
          _divider(),
          _buildStatCol('YEAR', movie.releaseYear, AppColors.textPrimary),
          _divider(),
          _buildStatCol('STATUS', movie.status ?? 'Released', AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 24, width: 1, color: AppColors.border);
  }

  Widget _buildStatCol(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: AppTypography.statLabel),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.statValue.copyWith(color: valueColor, fontSize: 13)),
      ],
    );
  }
}

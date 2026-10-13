import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/cast_member.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/movie_provider.dart';

/// ============================================================================
/// SCREEN: MovieDetailScreen
/// ============================================================================
/// Displays complete movie details by combining 3 distinct TMDB API endpoints:
/// 1. `GET /movie/{id}`                -> Full movie metadata (runtime, tagline, status)
/// 2. `GET /movie/{id}/credits`        -> Top billed cast & actor details
/// 3. `GET /movie/{id}/recommendations`-> Suggested movies ("You Might Also Like")
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  /// The movie instance whose details are presented
  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Trigger async loading for details, cast credits, and movie recommendations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovieDetailData(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, _) {
        // Use enriched selected movie details if available, otherwise fallback to widget.movie
        final movie = (provider.selectedMovie?.id == widget.movie.id)
            ? provider.selectedMovie!
            : widget.movie;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                tooltip: 'Refresh details',
                onPressed: () => provider.loadMovieDetailData(widget.movie.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: 16:9 Backdrop Banner Image ──────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      movie.backdropUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface2,
                        child: const Center(
                          child: Icon(Icons.movie, size: 64, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Section 2: Movie Title & Catchphrase / Tagline ─────────────
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

                // ── Section 3: Metadata Badges (Rating, Release Date, Runtime, Status)
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

                // ── Section 4: Plot Overview ─────────────────────────────────
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

                // ── Section 5: Actors / Cast Section (TMDB /movie/{id}/credits) 
                _buildCastSection(provider),
                const SizedBox(height: 24),

                // ── Section 6: Suggested Movies (TMDB /movie/{id}/recommendations) 
                _buildRecommendationsSection(provider),
                const SizedBox(height: 24),

                // ── Section 7: TMDB API Output Inspector Card ────────────────
                _buildApiInspectorCard(movie, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Actors / Cast Section ──────────────────────────────────────────────────
  Widget _buildCastSection(MovieProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_alt_rounded, size: 20, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              'Top Cast & Actors',
              style: AppTypography.sectionHeadline,
            ),
            if (provider.isCastLoading) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isCastLoading && provider.cast.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('Loading cast from TMDB credits API...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
          )
        else if (provider.cast.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('No cast information available for this movie.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.cast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final actor = provider.cast[index];
                return _ActorCard(actor: actor);
              },
            ),
          ),
      ],
    );
  }

  // ── Suggested Movies Section ───────────────────────────────────────────────
  Widget _buildRecommendationsSection(MovieProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(
              'Suggested Movies (More Like This)',
              style: AppTypography.sectionHeadline,
            ),
            if (provider.isRecommendationsLoading) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isRecommendationsLoading && provider.recommendations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text('Fetching recommendations from TMDB API...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
          )
        else if (provider.recommendations.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('No recommendations found for this title.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final suggested = provider.recommendations[index];
                return _SuggestedMovieCard(
                  movie: suggested,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: suggested),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // ── API Output Inspector Card ──────────────────────────────────────────────
  Widget _buildApiInspectorCard(Movie movie, MovieProvider provider) {
    return Container(
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
              const Icon(Icons.data_object_rounded, size: 20, color: AppColors.accent),
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
          const SizedBox(height: 8),
          Text(
            'Endpoints invoked on this screen: /movie/${movie.id}, /movie/${movie.id}/credits, /movie/${movie.id}/recommendations',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const Divider(color: AppColors.border, height: 20),
          _buildApiFieldRow('ID', movie.id.toString()),
          _buildApiFieldRow('Title', movie.title),
          _buildApiFieldRow('Vote Average', movie.voteAverage.toString()),
          _buildApiFieldRow('Release Date', movie.releaseDate),
          _buildApiFieldRow('Runtime', '${movie.runtime ?? '--'} mins'),
          _buildApiFieldRow('Actors Count', '${provider.cast.length} cast loaded'),
          _buildApiFieldRow('Suggested Count', '${provider.recommendations.length} movies loaded'),
          _buildApiFieldRow('Poster Path', movie.posterPath ?? 'null'),
          _buildApiFieldRow('Backdrop Path', movie.backdropPath ?? 'null'),
        ],
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
            width: 125,
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

/// ============================================================================
/// COMPONENT WIDGET: _ActorCard
/// ============================================================================
class _ActorCard extends StatelessWidget {
  const _ActorCard({required this.actor});

  final CastMember actor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 70,
              height: 70,
              child: Image.network(
                actor.profileUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  child: const Icon(Icons.person_rounded, size: 36, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actor.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (actor.character.isNotEmpty)
            Text(
              actor.character,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// COMPONENT WIDGET: _SuggestedMovieCard
/// ============================================================================
class _SuggestedMovieCard extends StatelessWidget {
  const _SuggestedMovieCard({
    required this.movie,
    required this.onTap,
  });

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: 110,
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  child: const Center(
                    child: Icon(Icons.movie_rounded, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(
                        movie.ratingFormatted,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

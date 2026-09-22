import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/search_provider.dart';
import '../widgets/genre_chip.dart';
import '../widgets/search_movie_card.dart';
import '../widgets/shimmer_skeleton.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchProvider>().search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text('Discover', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search movies, actors...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.search('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Genre Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final g = AppConstants.genres[index];
                  final isSelected = provider.selectedGenreId == g.id && provider.query.isEmpty;
                  return GenreChip(
                    label: g.name,
                    isActive: isSelected,
                    onTap: () {
                      _searchCtrl.clear();
                      provider.selectGenre(g.id);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.status == SearchStatus.loading) {
                    return const SingleChildScrollView(child: SearchGridSkeleton());
                  }

                  if (provider.status == SearchStatus.error) {
                    return ErrorView(
                      message: provider.errorMessage ?? 'Search failed',
                      onRetry: () => provider.search(provider.query),
                    );
                  }

                  if (provider.status == SearchStatus.empty) {
                    return const EmptyView(
                      icon: Icons.movie_filter_outlined,
                      title: 'No Movies Found',
                      subtitle: 'Try searching with another keyword or pick a different genre.',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: provider.results.length,
                    itemBuilder: (context, index) {
                      final movie = provider.results[index];
                      return SearchMovieCard(
                        movie: movie,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(movieId: movie.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

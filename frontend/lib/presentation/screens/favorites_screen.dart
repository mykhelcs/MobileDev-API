import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_typography.dart';
import '../providers/favorites_provider.dart';
import '../widgets/fav_item_tile.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    final movies = provider.movies;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Movies', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                '${movies.length} ${movies.length == 1 ? 'film' : 'films'} saved',
                style: AppTypography.label,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: movies.isEmpty
                    ? const EmptyView(
                        icon: Icons.bookmark_border_rounded,
                        title: 'No saved movies yet',
                        subtitle: 'Tap the bookmark icon on any movie to save it to your library.',
                      )
                    : ListView.builder(
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return FavItemTile(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(movieId: movie.id),
                                ),
                              ).then((_) => provider.load());
                            },
                            onDelete: () => provider.remove(movie.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

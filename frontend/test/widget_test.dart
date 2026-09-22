import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/core/models/movie.dart';
import 'package:api/core/models/cast_member.dart';
import 'package:api/core/models/watch_provider.dart';
import 'package:api/core/services/favorites_service.dart';
import 'package:api/presentation/widgets/genre_chip.dart';
import 'package:api/presentation/widgets/movie_poster_card.dart';
import 'package:api/presentation/widgets/now_playing_card.dart';
import 'package:api/presentation/widgets/fav_item_tile.dart';
import 'package:api/presentation/widgets/state_views.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testMovie = Movie(
    id: 101,
    title: 'Interstellar Voyage',
    overview: 'A deep space exploration adventure beyond known galaxies.',
    posterPath: '/path_to_poster.jpg',
    backdropPath: '/path_to_backdrop.jpg',
    voteAverage: 8.8,
    releaseDate: '2024-11-05',
    genreIds: const [878, 12],
    runtime: 169,
    tagline: 'Mankind was born on Earth. It was never meant to die here.',
    status: 'Released',
  );

  group('Movie Model & Formatting Tests', () {
    test('Movie properly computes derived getters', () {
      expect(testMovie.releaseYear, '2024');
      expect(testMovie.ratingFormatted, '8.8');
      expect(testMovie.runtimeFormatted, '2h 49m');
      expect(testMovie.posterUrl, contains('/path_to_poster.jpg'));
      expect(testMovie.backdropUrl, contains('/path_to_backdrop.jpg'));
    });

    test('Movie serialization round-trip', () {
      final json = testMovie.toJson();
      final fromJson = Movie.fromJson(json);
      expect(fromJson.id, testMovie.id);
      expect(fromJson.title, testMovie.title);
      expect(fromJson.voteAverage, testMovie.voteAverage);
      expect(fromJson == testMovie, isTrue);
    });

    test('CastMember serialization', () {
      final cast = CastMember.fromJson({
        'id': 1,
        'name': 'Matthew McConaughey',
        'character': 'Cooper',
        'profile_path': '/cooper.jpg',
      });
      expect(cast.name, 'Matthew McConaughey');
      expect(cast.character, 'Cooper');
      expect(cast.profileUrl, contains('/cooper.jpg'));
    });

    test('WatchProvider serialization', () {
      final provider = WatchProvider.fromJson({
        'provider_id': 8,
        'provider_name': 'Netflix',
        'logo_path': '/netflix.jpg',
      });
      expect(provider.providerId, 8);
      expect(provider.providerName, 'Netflix');
      expect(provider.logoUrl, contains('/netflix.jpg'));
    });
  });

  group('FavoritesService Tests', () {
    test('add, remove, and query favorites with SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final favService = FavoritesService(prefs);

      expect(favService.getAll(), isEmpty);
      expect(favService.isFavorite(testMovie.id), isFalse);

      await favService.add(testMovie);
      expect(favService.getAll().length, 1);
      expect(favService.isFavorite(testMovie.id), isTrue);

      await favService.toggle(testMovie);
      expect(favService.getAll(), isEmpty);
      expect(favService.isFavorite(testMovie.id), isFalse);
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('GenreChip displays label and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GenreChip(
              label: 'Sci-Fi',
              isActive: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sci-Fi'), findsOneWidget);
      await tester.tap(find.byType(GenreChip));
      expect(tapped, isTrue);
    });

    testWidgets('MoviePosterCard displays title, rank and rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviePosterCard(
              movie: testMovie,
              rank: 1,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Interstellar Voyage'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('8.8'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('NowPlayingCard displays title and rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NowPlayingCard(
              movie: testMovie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Interstellar Voyage'), findsOneWidget);
      expect(find.text('8.8'), findsOneWidget);
    });

    testWidgets('FavItemTile renders movie info and delete callback', (tester) async {
      bool deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavItemTile(
              movie: testMovie,
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Interstellar Voyage'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });

    testWidgets('EmptyView renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved movies',
              subtitle: 'Start exploring and bookmarking films.',
            ),
          ),
        ),
      );

      expect(find.text('No saved movies'), findsOneWidget);
      expect(find.text('Start exploring and bookmarking films.'), findsOneWidget);
    });

    testWidgets('ErrorView renders error message and retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Failed to connect to TMDB',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to connect to TMDB'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });
  });
}

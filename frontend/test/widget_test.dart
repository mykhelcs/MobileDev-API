import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:api/core/constants/app_constants.dart';
import 'package:api/core/models/cast_member.dart';
import 'package:api/core/models/movie.dart';
import 'package:api/core/services/tmdb_api_service.dart';
import 'package:api/presentation/providers/movie_provider.dart';
import 'package:api/presentation/screens/movie_list_screen.dart';
import 'package:api/presentation/screens/movie_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleDetailJson = {
    'id': 550,
    'title': 'Fight Club',
    'overview': 'A ticking-time-bomb insomniac and a slippery soap salesman...',
    'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
    'vote_average': 8.433,
    'release_date': '1999-10-15',
    'genre_ids': [18, 53],
    'runtime': 139,
    'tagline': 'Mischief. Mayhem. Soap.',
    'status': 'Released',
  };

  final sampleCastJson = {
    'id': 6193,
    'name': 'Leonardo DiCaprio',
    'character': 'Dom Cobb',
    'profile_path': '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
    'order': 0,
  };

  group('Movie & Cast Model Tests', () {
    test('Movie parses TMDB API response accurately', () {
      final movie = Movie.fromJson(sampleDetailJson);
      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.ratingFormatted, '8.4');
      expect(movie.releaseYear, '1999');
      expect(movie.runtimeFormatted, '2h 19m');
      expect(movie.posterUrl, contains('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(movie.backdropUrl, contains('/hZkgoQYus5vegHoetLkCJzb17zJ.jpg'));
    });

    test('Movie serialization round-trip', () {
      final movie = Movie.fromJson(sampleDetailJson);
      final json = movie.toJson();
      final fromJson = Movie.fromJson(json);
      expect(fromJson.id, movie.id);
      expect(fromJson.title, movie.title);
      expect(fromJson == movie, isTrue);
    });

    test('CastMember parses TMDB credits API accurately', () {
      final cast = CastMember.fromJson(sampleCastJson);
      expect(cast.id, 6193);
      expect(cast.name, 'Leonardo DiCaprio');
      expect(cast.character, 'Dom Cobb');
      expect(cast.profileUrl, contains('/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg'));

      final json = cast.toJson();
      final fromJson = CastMember.fromJson(json);
      expect(fromJson.id, cast.id);
      expect(fromJson.name, cast.name);
      expect(fromJson == cast, isTrue);
    });
  });

  group('TmdbApiService with Dio Tests (6 Endpoints)', () {
    test('1. fetchPopular fetches and parses movies', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/movie/popular')) {
          return ResponseBody.fromString(
            '''{
              "page": 1,
              "results": [
                {
                  "id": 550,
                  "title": "Fight Club",
                  "overview": "A ticking-time-bomb insomniac",
                  "poster_path": "/poster.jpg",
                  "backdrop_path": "/backdrop.jpg",
                  "vote_average": 8.4,
                  "release_date": "1999-10-15",
                  "genre_ids": [18]
                }
              ]
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final movies = await service.fetchPopular();

      expect(movies, isNotEmpty);
      expect(movies.first.title, 'Fight Club');
      expect(movies.first.id, 550);
    });

    test('2. fetchTopRated fetches top rated movies', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/movie/top_rated')) {
          return ResponseBody.fromString(
            '''{
              "page": 1,
              "results": [
                {
                  "id": 238,
                  "title": "The Godfather",
                  "overview": "Spanning the years 1945 to 1955...",
                  "poster_path": "/godfather.jpg",
                  "backdrop_path": "/godfather_bg.jpg",
                  "vote_average": 8.7,
                  "release_date": "1972-03-14",
                  "genre_ids": [18, 80]
                }
              ]
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final movies = await service.fetchTopRated();

      expect(movies, isNotEmpty);
      expect(movies.first.title, 'The Godfather');
      expect(movies.first.id, 238);
    });

    test('3. searchMovies searches movies by keyword query', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/search/movie') &&
            options.queryParameters['query'] == 'Inception') {
          return ResponseBody.fromString(
            '''{
              "page": 1,
              "results": [
                {
                  "id": 27205,
                  "title": "Inception",
                  "overview": "Cobb steals corporate secrets...",
                  "poster_path": "/inc.jpg",
                  "backdrop_path": "/inc_bg.jpg",
                  "vote_average": 8.4,
                  "release_date": "2010-07-15",
                  "genre_ids": [28, 878]
                }
              ]
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final results = await service.searchMovies('Inception');

      expect(results, isNotEmpty);
      expect(results.first.title, 'Inception');
      expect(results.first.id, 27205);
    });

    test('4. fetchMovieDetail fetches movie detail with Dio', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/movie/550')) {
          return ResponseBody.fromString(
            '''{
              "id": 550,
              "title": "Fight Club",
              "overview": "Detail overview",
              "poster_path": "/poster.jpg",
              "backdrop_path": "/backdrop.jpg",
              "vote_average": 8.4,
              "release_date": "1999-10-15",
              "runtime": 139,
              "tagline": "Soap."
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final detail = await service.fetchMovieDetail(550);

      expect(detail.id, 550);
      expect(detail.tagline, 'Soap.');
      expect(detail.runtime, 139);
    });

    test('5. fetchCredits fetches movie cast/actors', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/movie/550/credits')) {
          return ResponseBody.fromString(
            '''{
              "id": 550,
              "cast": [
                {
                  "id": 287,
                  "name": "Brad Pitt",
                  "character": "Tyler Durden",
                  "profile_path": "/brad.jpg",
                  "order": 0
                },
                {
                  "id": 819,
                  "name": "Edward Norton",
                  "character": "The Narrator",
                  "profile_path": "/edward.jpg",
                  "order": 1
                }
              ]
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final cast = await service.fetchCredits(550);

      expect(cast.length, 2);
      expect(cast.first.name, 'Brad Pitt');
      expect(cast.first.character, 'Tyler Durden');
      expect(cast.last.name, 'Edward Norton');
    });

    test('6. fetchRecommendations fetches suggested movies', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/movie/550/recommendations')) {
          return ResponseBody.fromString(
            '''{
              "page": 1,
              "results": [
                {
                  "id": 680,
                  "title": "Pulp Fiction",
                  "overview": "A burger-loving hit man...",
                  "poster_path": "/pulp.jpg",
                  "backdrop_path": "/pulp_bg.jpg",
                  "vote_average": 8.5,
                  "release_date": "1994-09-10",
                  "genre_ids": [53, 80]
                }
              ]
            }''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final service = TmdbApiService(apiKey: 'dummy_key', dio: dio);
      final recs = await service.fetchRecommendations(550);

      expect(recs.length, 1);
      expect(recs.first.title, 'Pulp Fiction');
      expect(recs.first.id, 680);
    });
  });

  group('MovieProvider State Management Tests', () {
    test('loadMovies & switchCategory populate category movies', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        final title = options.path.contains('top_rated') ? 'The Godfather' : 'Inception';
        return ResponseBody.fromString(
          '''{
            "page": 1,
            "results": [
              {
                "id": 100,
                "title": "$title",
                "overview": "Sample overview",
                "poster_path": "/sample.jpg",
                "backdrop_path": "/sample_bg.jpg",
                "vote_average": 8.8,
                "release_date": "2010-07-16",
                "genre_ids": [878]
              }
            ]
          }''',
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      await provider.loadMovies();
      expect(provider.movies.first.title, 'Inception');
      expect(provider.activeCategory, MovieCategory.popular);

      await provider.switchCategory(MovieCategory.topRated);
      expect(provider.activeCategory, MovieCategory.topRated);
      expect(provider.movies.first.title, 'The Godfather');
    });

    test('search and clearSearch update search state', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '''{
            "page": 1,
            "results": [
              {
                "id": 200,
                "title": "Avatar",
                "overview": "Pandora exploration",
                "poster_path": "/avatar.jpg",
                "backdrop_path": "/avatar_bg.jpg",
                "vote_average": 7.5,
                "release_date": "2009-12-15",
                "genre_ids": [28, 878]
              }
            ]
          }''',
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      expect(provider.isSearchActive, isFalse);
      await provider.search('Avatar');

      expect(provider.isSearchActive, isTrue);
      expect(provider.searchResults.length, 1);
      expect(provider.searchResults.first.title, 'Avatar');

      provider.clearSearch();
      expect(provider.isSearchActive, isFalse);
      expect(provider.searchResults, isEmpty);
    });

    test('loadMovieDetailData loads detail, cast, and recommendations concurrently', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.endsWith('/credits')) {
          return ResponseBody.fromString(
            '''{"id": 550, "cast": [{"id": 287, "name": "Brad Pitt", "character": "Tyler", "order": 0}]}''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.endsWith('/recommendations')) {
          return ResponseBody.fromString(
            '''{"results": [{"id": 680, "title": "Pulp Fiction", "overview": "Pulp", "poster_path": "/p.jpg", "backdrop_path": "/b.jpg", "vote_average": 8.5, "release_date": "1994-09-10", "genre_ids": [80]}]}''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(
          '''{"id": 550, "title": "Fight Club", "overview": "Detailed", "poster_path": "/p.jpg", "backdrop_path": "/b.jpg", "vote_average": 8.4, "release_date": "1999-10-15", "runtime": 139, "tagline": "Soap"}''',
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      await provider.loadMovieDetailData(550);

      expect(provider.selectedMovie?.title, 'Fight Club');
      expect(provider.cast.first.name, 'Brad Pitt');
      expect(provider.recommendations.first.title, 'Pulp Fiction');
    });
  });

  group('UI Presentation & Widget Display Tests', () {
    testWidgets('MovieListScreen displays search bar, category chips, and movie cards', (tester) async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '''{
            "page": 1,
            "results": [
              {
                "id": 100,
                "title": "Inception",
                "overview": "A thief who steals corporate secrets through dream-sharing technology.",
                "poster_path": "/inc.jpg",
                "backdrop_path": "/inc_bg.jpg",
                "vote_average": 8.8,
                "release_date": "2010-07-16",
                "genre_ids": [878]
              }
            ]
          }''',
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: MovieListScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('🔥 Popular'), findsOneWidget);
      expect(find.text('⭐ Top Rated'), findsOneWidget);
      expect(find.text('📈 Trending'), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);
    });

    testWidgets('MovieDetailScreen displays cast, suggested movies, and API inspector', (tester) async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.endsWith('/credits')) {
          return ResponseBody.fromString(
            '''{"id": 550, "cast": [{"id": 287, "name": "Brad Pitt", "character": "Tyler Durden", "order": 0}]}''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.endsWith('/recommendations')) {
          return ResponseBody.fromString(
            '''{"results": [{"id": 680, "title": "Pulp Fiction", "overview": "Pulp", "poster_path": "/p.jpg", "backdrop_path": "/b.jpg", "vote_average": 8.5, "release_date": "1994-09-10", "genre_ids": [80]}]}''',
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(
          '''{"id": 550, "title": "Fight Club", "overview": "Fight Club overview", "poster_path": "/p.jpg", "backdrop_path": "/b.jpg", "vote_average": 8.4, "release_date": "1999-10-15", "runtime": 139, "tagline": "Mischief. Mayhem. Soap."}''',
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);
      final movie = Movie.fromJson(sampleDetailJson);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: MovieDetailScreen(movie: movie),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Fight Club'), findsWidgets);
      expect(find.text('Top Cast & Actors'), findsOneWidget);
      expect(find.text('Suggested Movies (More Like This)'), findsOneWidget);
      expect(find.text('TMDB API Output Data'), findsOneWidget);
      expect(find.text('Brad Pitt'), findsOneWidget);
      expect(find.text('Tyler Durden'), findsOneWidget);
      expect(find.text('Pulp Fiction'), findsOneWidget);
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _MockHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

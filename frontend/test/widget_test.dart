import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
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

  group('Movie Model Tests', () {
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
  });

  group('TmdbApiService with Dio Tests', () {
    test('TmdbApiService fetches and parses movies using Dio', () async {
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
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
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

    test('TmdbApiService fetches movie detail with Dio', () async {
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
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
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
  });

  group('MovieProvider State Tests', () {
    test('loadMovies populates movies list from API service', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          '''{
            "page": 1,
            "results": [
              {
                "id": 100,
                "title": "Inception",
                "overview": "Dream within a dream",
                "poster_path": "/inc.jpg",
                "backdrop_path": "/inc_bg.jpg",
                "vote_average": 8.8,
                "release_date": "2010-07-16",
                "genre_ids": [878]
              }
            ]
          }''',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      expect(provider.isLoading, isFalse);
      expect(provider.movies, isEmpty);

      final future = provider.loadMovies();
      expect(provider.isLoading, isTrue);

      await future;
      expect(provider.isLoading, isFalse);
      expect(provider.movies.length, 1);
      expect(provider.movies.first.title, 'Inception');
    });

    test('loadMovies handles error gracefully', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        throw DioException(
          requestOptions: options,
          error: 'Connection refused',
        );
      });

      final service = TmdbApiService(apiKey: 'test_key', dio: dio);
      final provider = MovieProvider(service);

      await provider.loadMovies();
      expect(provider.isLoading, isFalse);
      expect(provider.movies, isEmpty);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('UI Presentation & API Output Display Tests', () {
    testWidgets('MovieListScreen displays movie API outputs', (tester) async {
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
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
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

      expect(find.text('Inception'), findsOneWidget);
      expect(find.textContaining('8.8'), findsOneWidget);
      expect(find.textContaining('2010'), findsOneWidget);
    });

    testWidgets('MovieDetailScreen displays full API details', (tester) async {
      final movie = Movie.fromJson(sampleDetailJson);

      await tester.pumpWidget(
        MaterialApp(
          home: MovieDetailScreen(movie: movie),
        ),
      );

      expect(find.text('Fight Club'), findsWidgets);
      expect(find.text('Mischief. Mayhem. Soap.'), findsOneWidget);
      expect(find.textContaining('2h 19m'), findsOneWidget);
      expect(find.text('8.4 / 10'), findsOneWidget);
      expect(find.textContaining('1999'), findsWidgets);
      expect(find.text(movie.overview), findsOneWidget);
      expect(find.text('TMDB API Output Data'), findsOneWidget);
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

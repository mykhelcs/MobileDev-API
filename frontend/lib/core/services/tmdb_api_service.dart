import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/movie.dart';

/// TMDB API v3 service using Dio as HTTP client/parser.
class TmdbApiService {
  TmdbApiService({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.tmdbBaseUrl,
              queryParameters: {'api_key': apiKey, 'language': 'en-US'},
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final String apiKey;
  final Dio _dio;

  /// Fetches popular movies from TMDB API (/movie/popular).
  Future<List<Movie>> fetchPopular({int page = 1}) async {
    final resp = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _parseResults(resp.data);
  }

  /// Fetches trending movies from TMDB API (/trending/movie/week).
  Future<List<Movie>> fetchTrending({int page = 1}) async {
    final resp = await _dio.get(
      '/trending/movie/week',
      queryParameters: {'page': page},
    );
    return _parseResults(resp.data);
  }

  /// Fetches details for a specific movie from TMDB API (/movie/{id}).
  Future<Movie> fetchMovieDetail(int movieId) async {
    final resp = await _dio.get('/movie/$movieId');
    return Movie.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  List<Movie> _parseResults(dynamic data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final results = map['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

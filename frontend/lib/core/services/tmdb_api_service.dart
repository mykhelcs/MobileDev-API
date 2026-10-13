import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/cast_member.dart';
import '../models/movie.dart';

/// ============================================================================
/// NETWORK SERVICE: TmdbApiService
/// ============================================================================
/// This service acts as the Network / Data Access Layer for our application.
/// It is responsible for making HTTP requests to The Movie Database (TMDB) API
/// and converting the raw responses into structured Dart objects.
///
/// Distinct TMDB Endpoints Implemented:
/// 1. Popular Movies:       GET /movie/popular
/// 2. Top Rated Movies:     GET /movie/top_rated
/// 3. Trending Movies:      GET /trending/movie/week
/// 4. Search Movies:        GET /search/movie?query={query}
/// 5. Movie Details:        GET /movie/{movieId}
/// 6. Movie Credits (Cast): GET /movie/{movieId}/credits
/// 7. Recommendations:      GET /movie/{movieId}/recommendations
class TmdbApiService {
  TmdbApiService({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.tmdbBaseUrl,
                queryParameters: {'api_key': apiKey, 'language': 'en-US'},
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// TMDB API Key used for query authentication
  final String apiKey;

  /// Underlying HTTP client instance
  final Dio _dio;

  // ── API Endpoints ──────────────────────────────────────────────────────────

  /// 1. Fetches a paginated list of popular movies.
  /// Endpoint: `GET /movie/popular?page={page}`
  Future<List<Movie>> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  /// 2. Fetches top rated movies of all time.
  /// Endpoint: `GET /movie/top_rated?page={page}`
  Future<List<Movie>> fetchTopRated({int page = 1}) async {
    final response = await _dio.get(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  /// 3. Fetches movies trending for the current week.
  /// Endpoint: `GET /trending/movie/week?page={page}`
  Future<List<Movie>> fetchTrending({int page = 1}) async {
    final response = await _dio.get(
      '/trending/movie/week',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  /// 4. Searches movies matching a user query string.
  /// Endpoint: `GET /search/movie?query={query}&page={page}`
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final response = await _dio.get(
      '/search/movie',
      queryParameters: {
        'query': trimmed,
        'page': page,
      },
    );
    return _parseResults(response.data);
  }

  /// 5. Fetches full details for a single movie by its TMDB ID.
  /// Endpoint: `GET /movie/{movieId}`
  Future<Movie> fetchMovieDetail(int movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return Movie.fromJson(response.data as Map<String, dynamic>);
  }

  /// 6. Fetches actor / cast credits for a given movie.
  /// Endpoint: `GET /movie/{movieId}/credits`
  Future<List<CastMember>> fetchCredits(int movieId) async {
    final response = await _dio.get('/movie/$movieId/credits');
    return _parseCast(response.data);
  }

  /// 7. Fetches suggested / recommended movies for a given movie.
  /// Endpoint: `GET /movie/{movieId}/recommendations?page={page}`
  Future<List<Movie>> fetchRecommendations(int movieId, {int page = 1}) async {
    final response = await _dio.get(
      '/movie/$movieId/recommendations',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  // ── Helper: JSON Response Parsers ──────────────────────────────────────────

  /// Parses the TMDB API standard envelope `{ page: 1, results: [...] }`
  /// and converts each result item into a [Movie] instance.
  List<Movie> _parseResults(dynamic data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final results = map['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parses the TMDB API credits envelope `{ id: ..., cast: [...] }`
  /// and converts each cast member into a [CastMember] instance.
  List<CastMember> _parseCast(dynamic data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final castList = map['cast'] as List<dynamic>? ?? [];
    return castList
        .map((item) => CastMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/movie.dart';

/// ============================================================================
/// NETWORK SERVICE: TmdbApiService
/// ============================================================================
/// This service acts as the Network / Data Access Layer for our application.
/// It is responsible for making HTTP requests to The Movie Database (TMDB) API
/// and converting the raw responses into structured [Movie] objects.
///
/// Why use Dio instead of standard http?
/// - Automatic JSON parsing: `response.data` is already decoded into a Dart Map/List.
/// - BaseOptions: Centralizes base URLs, default query parameters, and timeout configs.
/// - Testability: An optional `Dio` client can be passed in during unit tests to
///   mock network calls without hitting real servers.
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

  /// Fetches a paginated list of popular movies.
  /// Endpoint: `GET /movie/popular?page={page}`
  Future<List<Movie>> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  /// Fetches movies trending for the current week.
  /// Endpoint: `GET /trending/movie/week?page={page}`
  Future<List<Movie>> fetchTrending({int page = 1}) async {
    final response = await _dio.get(
      '/trending/movie/week',
      queryParameters: {'page': page},
    );
    return _parseResults(response.data);
  }

  /// Fetches full details for a single movie by its TMDB ID.
  /// Endpoint: `GET /movie/{movieId}`
  Future<Movie> fetchMovieDetail(int movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return Movie.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Helper: JSON Response Parser ───────────────────────────────────────────

  /// Parses the TMDB API standard envelope `{ page: 1, results: [...] }`
  /// and converts each result item into a [Movie] instance.
  List<Movie> _parseResults(dynamic data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final results = map['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

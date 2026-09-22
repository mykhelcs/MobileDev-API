import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../models/movie.dart';
import '../models/cast_member.dart';
import '../models/watch_provider.dart';

/// TMDB API v3 service.
/// Insert your TMDB API key in [apiKey]. For production, load from env/secure storage.
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

  // ── Movie Lists ─────────────────────────────────────────────────────────────

  Future<List<Movie>> fetchTrending({int page = 1}) async {
    final resp = await _dio.get(
      '/trending/movie/week',
      queryParameters: {'page': page},
    );
    return _parseResults(resp.data);
  }

  Future<List<Movie>> fetchNowPlaying({int page = 1}) async {
    final resp = await _dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );
    return _parseResults(resp.data);
  }

  Future<List<Movie>> fetchPopular({int page = 1}) async {
    final resp = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _parseResults(resp.data);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final resp = await _dio.get(
      '/search/movie',
      queryParameters: {'query': query, 'page': page},
    );
    return _parseResults(resp.data);
  }

  Future<List<Movie>> discoverByGenre(int genreId, {int page = 1}) async {
    final params = <String, dynamic>{'page': page, 'sort_by': 'popularity.desc'};
    if (genreId != 0) params['with_genres'] = genreId;
    final resp = await _dio.get('/discover/movie', queryParameters: params);
    return _parseResults(resp.data);
  }

  // ── Movie Detail ────────────────────────────────────────────────────────────

  Future<Movie> fetchMovieDetail(int movieId) async {
    final resp = await _dio.get('/movie/$movieId');
    return Movie.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<CastMember>> fetchCast(int movieId) async {
    final resp = await _dio.get('/movie/$movieId/credits');
    final cast = (resp.data['cast'] as List<dynamic>? ?? []);
    return cast
        .take(15)
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<WatchProvider>> fetchWatchProviders(
    int movieId, {
    String region = 'US',
  }) async {
    final resp = await _dio.get('/movie/$movieId/watch/providers');
    final results = resp.data['results'] as Map<String, dynamic>? ?? {};
    final regionData = results[region] as Map<String, dynamic>? ?? {};
    final flatrate = regionData['flatrate'] as List<dynamic>? ?? [];
    return flatrate
        .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<Movie> _parseResults(dynamic data) {
    final results = (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

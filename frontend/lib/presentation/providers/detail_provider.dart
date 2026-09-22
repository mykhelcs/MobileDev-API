import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/models/cast_member.dart';
import '../../core/models/watch_provider.dart';
import '../../core/services/tmdb_api_service.dart';
import '../../core/services/favorites_service.dart';

enum DetailStatus { initial, loading, success, error }

class DetailProvider extends ChangeNotifier {
  DetailProvider({required TmdbApiService api, required FavoritesService favoritesService})
      : _api = api,
        _favoritesService = favoritesService;

  final TmdbApiService _api;
  final FavoritesService _favoritesService;

  DetailStatus _status = DetailStatus.initial;
  DetailStatus get status => _status;

  Movie? _movie;
  List<CastMember> _cast = [];
  List<WatchProvider> _watchProviders = [];
  String? _errorMessage;
  bool _isFavorite = false;

  Movie? get movie => _movie;
  List<CastMember> get cast => _cast;
  List<WatchProvider> get watchProviders => _watchProviders;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;

  Future<void> loadDetail(int movieId) async {
    _status = DetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchMovieDetail(movieId),
        _api.fetchCast(movieId),
        _api.fetchWatchProviders(movieId),
      ]);

      _movie = results[0] as Movie;
      _cast = results[1] as List<CastMember>;
      _watchProviders = results[2] as List<WatchProvider>;
      _isFavorite = _favoritesService.isFavorite(movieId);
      _status = DetailStatus.success;
    } catch (e) {
      _status = DetailStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_movie == null) return;
    await _favoritesService.toggle(_movie!);
    _isFavorite = _favoritesService.isFavorite(_movie!.id);
    notifyListeners();
  }
}

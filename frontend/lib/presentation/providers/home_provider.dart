import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/services/tmdb_api_service.dart';

enum HomeStatus { initial, loading, success, error }

/// Provider for HomeScreen: trending, now playing, and paginated popular.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._api);

  final TmdbApiService _api;

  HomeStatus _status = HomeStatus.initial;
  HomeStatus get status => _status;

  List<Movie> _trending = [];
  List<Movie> _nowPlaying = [];
  List<Movie> _popular = [];
  String? _errorMessage;
  bool _loadingMore = false;
  int _popularPage = 1;
  bool _hasMorePopular = true;
  Movie? _heroMovie;

  List<Movie> get trending => _trending;
  List<Movie> get nowPlaying => _nowPlaying;
  List<Movie> get popular => _popular;
  String? get errorMessage => _errorMessage;
  bool get loadingMore => _loadingMore;
  bool get hasMorePopular => _hasMorePopular;
  Movie? get heroMovie => _heroMovie;

  Future<void> loadInitial() async {
    if (_status == HomeStatus.loading) return;
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchTrending(),
        _api.fetchNowPlaying(),
        _api.fetchPopular(page: 1),
      ]);

      _trending = results[0];
      _nowPlaying = results[1];
      _popular = results[2];
      _popularPage = 1;
      _hasMorePopular = _popular.length >= 20;
      _heroMovie = _trending.isNotEmpty ? _trending.first : null;
      _status = HomeStatus.success;
    } catch (e) {
      _status = HomeStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadMorePopular() async {
    if (_loadingMore || !_hasMorePopular) return;
    _loadingMore = true;
    notifyListeners();

    try {
      final next = await _api.fetchPopular(page: _popularPage + 1);
      _popularPage++;
      _popular = [..._popular, ...next];
      _hasMorePopular = next.length >= 20;
    } catch (_) {
      // silently fail; user can scroll up and retry
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/services/tmdb_api_service.dart';

enum SearchStatus { initial, loading, success, empty, error }

class SearchProvider extends ChangeNotifier {
  SearchProvider(this._api);

  final TmdbApiService _api;

  SearchStatus _status = SearchStatus.initial;
  SearchStatus get status => _status;

  List<Movie> _results = [];
  List<Movie> get results => _results;

  String _query = '';
  String get query => _query;

  int _selectedGenreId = 0;
  int get selectedGenreId => _selectedGenreId;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> search(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      await _loadDiscover();
      return;
    }

    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _api.searchMovies(query);
      _status = _results.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> selectGenre(int genreId) async {
    _selectedGenreId = genreId;
    _query = '';
    await _loadDiscover();
  }

  Future<void> _loadDiscover() async {
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      _results = await _api.discoverByGenre(_selectedGenreId);
      _status = _results.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> initialize() => _loadDiscover();
}

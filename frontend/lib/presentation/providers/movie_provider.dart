import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/services/tmdb_api_service.dart';

/// Provider for managing TMDB Movie API data.
/// Clean, deterministic state management using Dio as the HTTP fetcher.
class MovieProvider extends ChangeNotifier {
  MovieProvider(this._apiService);

  final TmdbApiService _apiService;

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  Movie? _selectedMovie;
  bool _isDetailLoading = false;
  String? _detailErrorMessage;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Movie? get selectedMovie => _selectedMovie;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailErrorMessage => _detailErrorMessage;

  /// Loads popular movies from TMDB API using Dio.
  Future<void> loadMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movies = await _apiService.fetchPopular();
    } catch (e) {
      _errorMessage = 'Failed to load movies from API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the currently selected movie.
  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  /// Loads full details for a movie from TMDB API using Dio.
  Future<void> loadMovieDetail(int movieId) async {
    _isDetailLoading = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      _selectedMovie = await _apiService.fetchMovieDetail(movieId);
    } catch (e) {
      _detailErrorMessage = 'Failed to load movie details: $e';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}

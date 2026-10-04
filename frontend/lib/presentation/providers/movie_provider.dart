import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/services/tmdb_api_service.dart';

/// ============================================================================
/// STATE MANAGEMENT: MovieProvider
/// ============================================================================
/// In Flutter, a "Provider" acts as the bridge between business logic/data
/// and the user interface.
///
/// By extending [ChangeNotifier], this class can notify listening widgets
/// whenever data changes via `notifyListeners()`. Widgets subscribed to this
/// provider will automatically rebuild with the latest state.
///
/// Typical State Pattern for Asynchronous Operations:
/// 1. Start: Set `isLoading = true`, reset `errorMessage = null`, call `notifyListeners()`.
/// 2. Fetch: Await data from the service.
/// 3. Success: Assign data to state variables.
/// 4. Error: Catch exception and store readable error message.
/// 5. Complete: Set `isLoading = false`, call `notifyListeners()` to update the UI.
class MovieProvider extends ChangeNotifier {
  MovieProvider(this._apiService);

  final TmdbApiService _apiService;

  // ── State Variables (Private to prevent direct mutation outside provider) ──

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  Movie? _selectedMovie;
  bool _isDetailLoading = false;
  String? _detailErrorMessage;

  // ── Public Getters (Read-only access for UI widgets) ────────────────────────

  /// The current list of loaded movies
  List<Movie> get movies => _movies;

  /// Whether movie list data is actively being fetched
  bool get isLoading => _isLoading;

  /// Error message string if movie list fetching failed, null otherwise
  String? get errorMessage => _errorMessage;

  /// The currently viewed or selected movie
  Movie? get selectedMovie => _selectedMovie;

  /// Whether movie detail data is actively being fetched
  bool get isDetailLoading => _isDetailLoading;

  /// Error message string if movie detail fetching failed, null otherwise
  String? get detailErrorMessage => _detailErrorMessage;

  // ── Intent Actions ─────────────────────────────────────────────────────────

  /// Fetches popular movies from the TMDB API service.
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

  /// Updates the currently selected movie synchronously (e.g. on tile tap).
  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  /// Fetches full movie details (runtime, tagline, status) from the TMDB API.
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

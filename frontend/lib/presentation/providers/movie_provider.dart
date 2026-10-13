import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/cast_member.dart';
import '../../core/models/movie.dart';
import '../../core/services/tmdb_api_service.dart';

/// ============================================================================
/// STATE MANAGEMENT: MovieProvider
/// ============================================================================
/// Manages reactive state across all 6 TMDB API features:
/// 1. Category Feeds (Popular, Top Rated, Trending)
/// 2. Live Keyword Search
/// 3. Movie Detail Metadata
/// 4. Movie Cast / Actors
/// 5. Recommended / Suggested Movies
class MovieProvider extends ChangeNotifier {
  MovieProvider(this._apiService);

  final TmdbApiService _apiService;

  // ── 1. Category Feed State ─────────────────────────────────────────────────
  MovieCategory? _activeCategory = MovieCategory.popular;
  List<Movie>? _movies = [];
  bool? _isLoading = false;
  String? _errorMessage;

  MovieCategory get activeCategory => _activeCategory ?? MovieCategory.popular;
  List<Movie> get movies => _movies ?? const [];
  bool get isLoading => _isLoading ?? false;
  String? get errorMessage => _errorMessage;

  // ── 2. Search State ────────────────────────────────────────────────────────
  String? _searchQuery = '';
  List<Movie>? _searchResults = [];
  bool? _isSearching = false;
  String? _searchErrorMessage;

  String get searchQuery => _searchQuery ?? '';
  List<Movie> get searchResults => _searchResults ?? const [];
  bool get isSearching => _isSearching ?? false;
  String? get searchErrorMessage => _searchErrorMessage;
  bool get isSearchActive => (_searchQuery ?? '').trim().isNotEmpty;

  // ── 3. Detail, Cast & Recommendations State ────────────────────────────────
  Movie? _selectedMovie;
  bool? _isDetailLoading = false;
  String? _detailErrorMessage;

  List<CastMember>? _cast = [];
  bool? _isCastLoading = false;
  String? _castErrorMessage;

  List<Movie>? _recommendations = [];
  bool? _isRecommendationsLoading = false;
  String? _recommendationsErrorMessage;

  Movie? get selectedMovie => _selectedMovie;
  bool get isDetailLoading => _isDetailLoading ?? false;
  String? get detailErrorMessage => _detailErrorMessage;

  List<CastMember> get cast => _cast ?? const [];
  bool get isCastLoading => _isCastLoading ?? false;
  String? get castErrorMessage => _castErrorMessage;

  List<Movie> get recommendations => _recommendations ?? const [];
  bool get isRecommendationsLoading => _isRecommendationsLoading ?? false;
  String? get recommendationsErrorMessage => _recommendationsErrorMessage;

  // ── Intent Actions: Category Feeds ─────────────────────────────────────────

  /// Loads movies for the currently selected category (defaults to Popular).
  Future<void> loadMovies() async {
    await loadCategoryMovies(activeCategory);
  }

  /// Switches active category and triggers API fetch.
  Future<void> switchCategory(MovieCategory category) async {
    if (activeCategory == category && movies.isNotEmpty) return;
    _activeCategory = category;
    notifyListeners();
    await loadCategoryMovies(category);
  }

  /// Fetches movies based on category from the appropriate TMDB endpoint.
  Future<void> loadCategoryMovies(MovieCategory category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (category) {
        case MovieCategory.popular:
          _movies = await _apiService.fetchPopular();
          break;
        case MovieCategory.topRated:
          _movies = await _apiService.fetchTopRated();
          break;
        case MovieCategory.trending:
          _movies = await _apiService.fetchTrending();
          break;
      }
    } catch (e) {
      _errorMessage = 'Failed to load ${category.label} movies: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Intent Actions: Search ─────────────────────────────────────────────────

  /// Executes live keyword search against TMDB `/search/movie` API.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    _searchQuery = query;

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(trimmed);
    } catch (e) {
      _searchErrorMessage = 'Search failed: $e';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clears active search query and resets back to category feed.
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _searchErrorMessage = null;
    notifyListeners();
  }

  // ── Intent Actions: Movie Details, Cast & Recommendations ──────────────────

  /// Updates selected movie and immediately resets sub-resource state.
  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    _cast = [];
    _recommendations = [];
    _detailErrorMessage = null;
    _castErrorMessage = null;
    _recommendationsErrorMessage = null;
    notifyListeners();
  }

  /// Fetches movie details alone (backward compatibility).
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

  /// Concurrently loads full movie details, actor credits, and recommendations.
  Future<void> loadMovieDetailData(int movieId) async {
    _isDetailLoading = true;
    _isCastLoading = true;
    _isRecommendationsLoading = true;
    _detailErrorMessage = null;
    _castErrorMessage = null;
    _recommendationsErrorMessage = null;
    notifyListeners();

    // 1. Fetch full details
    try {
      _selectedMovie = await _apiService.fetchMovieDetail(movieId);
    } catch (e) {
      _detailErrorMessage = 'Failed to load movie details: $e';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }

    // 2. Fetch actor cast
    try {
      _cast = await _apiService.fetchCredits(movieId);
    } catch (e) {
      _castErrorMessage = 'Failed to load cast: $e';
    } finally {
      _isCastLoading = false;
      notifyListeners();
    }

    // 3. Fetch recommendations
    try {
      _recommendations = await _apiService.fetchRecommendations(movieId);
    } catch (e) {
      _recommendationsErrorMessage = 'Failed to load recommendations: $e';
    } finally {
      _isRecommendationsLoading = false;
      notifyListeners();
    }
  }
}

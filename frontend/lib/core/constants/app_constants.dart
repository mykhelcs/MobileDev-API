/// App-wide constants.
abstract final class AppConstants {
  // TMDB base URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterW500 = '$tmdbImageBaseUrl/w500';
  static const String backdropW1280 = '$tmdbImageBaseUrl/w1280';
  static const String profileW185 = '$tmdbImageBaseUrl/w185';

  // Placeholder when no image available
  static const String placeholderUrl = 'https://via.placeholder.com/300x450?text=No+Image';

  // Genres list (TMDB genre IDs mapped to names for filter chips)
  static const List<({int id, String name})> genres = [
    (id: 0,     name: 'All'),
    (id: 28,    name: 'Action'),
    (id: 878,   name: 'Sci-Fi'),
    (id: 18,    name: 'Drama'),
    (id: 27,    name: 'Horror'),
    (id: 35,    name: 'Comedy'),
    (id: 10749, name: 'Romance'),
    (id: 53,    name: 'Thriller'),
    (id: 16,    name: 'Animation'),
    (id: 12,    name: 'Adventure'),
  ];

  // Shared Prefs key
  static const String favoritesKey = 'moviehub_favorites';
}

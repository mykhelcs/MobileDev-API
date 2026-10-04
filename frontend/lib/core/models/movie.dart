import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// ============================================================================
/// DATA MODEL: Movie
/// ============================================================================
/// A Data Model in Dart represents the structured shape of data our app works with.
/// In this application, [Movie] mirrors the response fields returned by The Movie
/// Database (TMDB) API.
///
/// Features of this model:
/// - Marked `@immutable` to prevent accidental state mutation after creation.
/// - Implements [Movie.fromJson] to convert raw API JSON maps into type-safe Dart objects.
/// - Implements [toJson] to support serialization / debugging.
/// - Provides helper getters (`posterUrl`, `ratingFormatted`, etc.) for convenient UI rendering.
@immutable
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    this.runtime,
    this.tagline,
    this.status,
  });

  /// Unique TMDB movie identifier
  final int id;

  /// Full movie title (e.g. "Inception")
  final String title;

  /// Plot synopsis / description
  final String overview;

  /// Relative path to movie poster image on TMDB servers
  final String? posterPath;

  /// Relative path to horizontal banner / backdrop image
  final String? backdropPath;

  /// Average vote score from 0.0 to 10.0
  final double voteAverage;

  /// Release date formatted as "YYYY-MM-DD"
  final String releaseDate;

  /// List of TMDB numeric genre identifiers
  final List<int> genreIds;

  /// Total duration in minutes (e.g. 148)
  final int? runtime;

  /// Marketing promotional tagline
  final String? tagline;

  /// Production release status (e.g. "Released", "In Production")
  final String? status;

  // ── Helper Getters (UI Convenience) ───────────────────────────────────────────

  /// Full URL for displaying the poster image (with placeholder fallback)
  String get posterUrl => posterPath != null
      ? '${AppConstants.posterW500}$posterPath'
      : AppConstants.placeholderUrl;

  /// Full URL for displaying the backdrop banner (with placeholder fallback)
  String get backdropUrl => backdropPath != null
      ? '${AppConstants.backdropW1280}$backdropPath'
      : AppConstants.placeholderUrl;

  /// Extracts the 4-digit release year from "YYYY-MM-DD"
  String get releaseYear => releaseDate.isNotEmpty && releaseDate.length >= 4
      ? releaseDate.substring(0, 4)
      : '--';

  /// Returns rating rounded to one decimal place (e.g. "8.4")
  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  /// Converts duration in minutes into a human-readable string (e.g. "2h 28m")
  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '--';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  // ── JSON Deserialization (Factory Constructor) ──────────────────────────────

  /// Creates a [Movie] instance from a decoded JSON map.
  /// Handles null values and type casting gracefully to avoid runtime crashes.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      releaseDate: (json['release_date'] as String?) ?? '',
      genreIds: ((json['genre_ids'] as List<dynamic>?) ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      status: json['status'] as String?,
    );
  }

  // ── JSON Serialization ─────────────────────────────────────────────────────

  /// Converts this [Movie] instance back into a raw Map structure.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'release_date': releaseDate,
        'genre_ids': genreIds,
        'runtime': runtime,
        'tagline': tagline,
        'status': status,
      };

  // ── Equality & HashCode (for reliable state comparisons and testing) ─────────

  @override
  bool operator ==(Object other) => other is Movie && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}

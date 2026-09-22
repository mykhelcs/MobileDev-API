import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Immutable Movie model. Maps 1:1 to TMDB API response fields.
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

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final int? runtime;
  final String? tagline;
  final String? status;

  String get posterUrl => posterPath != null
      ? '${AppConstants.posterW500}$posterPath'
      : AppConstants.placeholderUrl;

  String get backdropUrl => backdropPath != null
      ? '${AppConstants.backdropW1280}$backdropPath'
      : AppConstants.placeholderUrl;

  String get releaseYear => releaseDate.isNotEmpty
      ? releaseDate.substring(0, 4)
      : '--';

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '--';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

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

  @override
  bool operator ==(Object other) => other is Movie && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}

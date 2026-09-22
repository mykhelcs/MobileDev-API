import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/movie.dart';

/// Persists favorite movies locally using SharedPreferences.
class FavoritesService {
  FavoritesService(this._prefs);

  final SharedPreferences _prefs;

  List<Movie> getAll() {
    final raw = _prefs.getStringList(AppConstants.favoritesKey) ?? [];
    return raw
        .map((e) => Movie.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  bool isFavorite(int movieId) {
    return getAll().any((m) => m.id == movieId);
  }

  Future<void> add(Movie movie) async {
    final list = getAll();
    if (!list.any((m) => m.id == movie.id)) {
      list.add(movie);
      await _save(list);
    }
  }

  Future<void> remove(int movieId) async {
    final list = getAll().where((m) => m.id != movieId).toList();
    await _save(list);
  }

  Future<void> toggle(Movie movie) async {
    if (isFavorite(movie.id)) {
      await remove(movie.id);
    } else {
      await add(movie);
    }
  }

  Future<void> _save(List<Movie> movies) async {
    await _prefs.setStringList(
      AppConstants.favoritesKey,
      movies.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }
}

import 'package:flutter/foundation.dart';
import '../../core/models/movie.dart';
import '../../core/services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._service);

  final FavoritesService _service;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  void load() {
    _movies = _service.getAll();
    notifyListeners();
  }

  Future<void> remove(int movieId) async {
    await _service.remove(movieId);
    load();
  }
}

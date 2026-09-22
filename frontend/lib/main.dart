import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/tmdb_api_service.dart';
import 'core/services/favorites_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // You can set your TMDB API key here or via String.fromEnvironment('TMDB_API_KEY')
  const tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: 'YOUR_TMDB_API_KEY_HERE',
  );

  final tmdbService = TmdbApiService(apiKey: tmdbApiKey);
  final favoritesService = FavoritesService(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbApiService>.value(value: tmdbService),
        Provider<FavoritesService>.value(value: favoritesService),
        ChangeNotifierProvider(create: (_) => HomeProvider(tmdbService)),
        ChangeNotifierProvider(create: (_) => SearchProvider(tmdbService)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(favoritesService)),
      ],
      child: const MovieHubApp(),
    ),
  );
}

class MovieHubApp extends StatelessWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/services/tmdb_api_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/screens/movie_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file if present
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Gracefully handle missing or inaccessible .env
  }

  final tmdbApiKey = dotenv.env['TMDB_API_KEY'] ??
      const String.fromEnvironment(
        'TMDB_API_KEY',
        defaultValue: 'YOUR_TMDB_API_KEY_HERE',
      );

  final tmdbService = TmdbApiService(apiKey: tmdbApiKey);

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbApiService>.value(value: tmdbService),
        ChangeNotifierProvider(create: (_) => MovieProvider(tmdbService)),
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
      title: 'MovieHub — TMDB API Viewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MovieListScreen(),
    );
  }
}

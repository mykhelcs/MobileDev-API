import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/services/tmdb_api_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/movie_provider.dart';
import 'presentation/screens/movie_list_screen.dart';

/// ============================================================================
/// APPLICATION ENTRY POINT (main)
/// ============================================================================
/// The [main] function is the starting point of any Flutter application.
/// Here we perform asynchronous bootstrap tasks before launching the UI:
/// 1. Initialize Flutter engine bindings (`WidgetsFlutterBinding.ensureInitialized()`).
/// 2. Load API credentials from the local `.env` environment file.
/// 3. Instantiate the HTTP network service (`TmdbApiService`).
/// 4. Setup dependency injection using `MultiProvider`.
/// 5. Start the widget tree with `runApp()`.
void main() async {
  // Required when performing async initialization before calling runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Load environment variables safely (e.g., TMDB API Key)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing or unreadable, fall back gracefully
  }

  // Step 2: Retrieve API key with a fallback default for demo/testing
  final tmdbApiKey = dotenv.env['TMDB_API_KEY'] ??
      const String.fromEnvironment(
        'TMDB_API_KEY',
        defaultValue: 'YOUR_TMDB_API_KEY_HERE',
      );

  // Step 3: Create the singleton network service instance
  final tmdbService = TmdbApiService(apiKey: tmdbApiKey);

  // Step 4: Launch the application wrapped in Provider for global state access
  runApp(
    MultiProvider(
      providers: [
        // Provides the API service to any descendant widget
        Provider<TmdbApiService>.value(value: tmdbService),

        // Provides the reactive Movie state manager to the UI
        ChangeNotifierProvider(create: (_) => MovieProvider(tmdbService)),
      ],
      child: const MovieHubApp(),
    ),
  );
}

/// ============================================================================
/// ROOT APPLICATION WIDGET
/// ============================================================================
/// [MovieHubApp] configures the global settings for the app:
/// - Application title
/// - Dark theme styling via `AppTheme.dark`
/// - The initial screen shown to the user (`MovieListScreen`)
class MovieHubApp extends StatelessWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieHub - Your Movie Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MovieListScreen(),
    );
  }
}

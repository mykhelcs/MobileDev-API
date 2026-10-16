# MovieHub — Discover & Track Movies

**Owner:** Glenn Mykhel V. Gulfan  
**Group Members:**
- Glenn Mykhel V. Gulfan
- Jayshan Godornes
- Sean Cole Calixton
- Ranela Esgana

---

A modern Flutter mobile application that connects to [The Movie Database (TMDB) API](https://www.themoviedb.org/) to search, discover, and inspect movies. The application consumes **6 distinct TMDB REST API endpoints** using Dio for HTTP networking, Provider for reactive state management, and a custom Material 3 dark UI theme styled with Google Fonts (`Playfair Display` and `Outfit`).

---

## TMDB API Endpoints Implemented

The application integrates the following distinct REST API endpoints:

| # | Endpoint | Method | Feature & UI Placement |
|---|---|---|---|
| **1** | `/movie/popular` | `GET` | Popular movies catalog feed on Home Screen |
| **2** | `/movie/top_rated` | `GET` | "Top Rated" category feed on Home Screen |
| **3** | `/trending/movie/week` | `GET` | "Trending" category feed on Home Screen |
| **4** | `/search/movie?query={query}` | `GET` | Interactive Search bar with real-time results on Home Screen |
| **5** | `/movie/{movieId}` | `GET` | Detailed specs (runtime, tagline, status) on Detail Screen |
| **6** | `/movie/{movieId}/credits` | `GET` | Top Cast & Actors horizontal carousel on Detail Screen |
| **7** | `/movie/{movieId}/recommendations` | `GET` | Suggested Movies ("You Might Also Like") on Detail Screen |

---

## Features

- **Multi-Endpoint TMDB Integration:** Calls 6 distinct TMDB REST API endpoints using `Dio` with centralized query authentication and error handling.
- **Interactive Search:** Live keyword search with clear action, loading spinners, result counters, and dedicated empty-state feedback.
- **Category Feed Switcher:** Instant category chips on the main catalog screen (`🔥 Popular`, `⭐ Top Rated`, `📈 Trending`) fetching their respective endpoints.
- **Actor & Cast Showcase:** Horizontal carousel of top-billed actors displaying circular actor portraits, real names, and in-movie character names.
- **Suggested Movies ("More Like This"):** Horizontal recommendation carousel showing movie posters, ratings, and titles. Tapping any suggested movie navigates directly to its detail screen.
- **Movie Catalog Screen:** Displays movie cards with high-resolution poster thumbnails, titles, star ratings, release years, and synopsis previews.
- **Pull-to-Refresh & Reload:** Refresh list on-demand via pull-to-refresh (`RefreshIndicator`) or the AppBar reload action.
- **Detailed Movie View:** 16:9 backdrop banner, promotional tagline, release date, runtime, status, rating badge, and full plot overview.
- **API Output Inspector:** Dedicated on-screen data inspector card confirming parsed API JSON fields and displaying all endpoints invoked on the screen.
- **Cinematic Dark Theme:** Material 3 dark theme with custom color tokens and typography via Google Fonts (`Playfair Display` and `Outfit`).
- **Automated Testing Suite:** 14 automated unit and widget tests covering models, Dio mock client adapters, Provider state management, and widget rendering.

---

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (SDK `^3.11.3`) |
| **Language** | [Dart](https://dart.dev/) |
| **Networking** | [Dio](https://pub.dev/packages/dio) (`^5.7.0`) |
| **State Management** | [Provider](https://pub.dev/packages/provider) (`^6.1.2`) |
| **Configuration** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (`^5.2.1`) |
| **UI & Theming** | Material 3 Dark Palette |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) (`Playfair Display` & `Outfit`) |
| **Testing** | Flutter Test Framework (`flutter_test`), `mocktail` |

---

## Project Structure

```text
frontend/
├── .env                                # TMDB API Key configuration
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart      # Base TMDB URLs, image paths, genres, and MovieCategory enum
│   │   ├── models/
│   │   │   ├── cast_member.dart        # CastMember model with profile image helpers
│   │   │   └── movie.dart              # Movie data model with JSON deserialization & getters
│   │   ├── services/
│   │   │   └── tmdb_api_service.dart   # Network service implementing all 6 TMDB endpoints using Dio
│   │   └── theme/
│   │       ├── app_colors.dart         # Color constants and design tokens
│   │       ├── app_theme.dart          # Custom dark theme configuration
│   │       └── app_typography.dart     # Google Fonts text styles
│   ├── presentation/
│   │   ├── providers/
│   │   │   └── movie_provider.dart     # ChangeNotifier managing feeds, search, cast, and recommendations
│   │   └── screens/
│   │       ├── movie_list_screen.dart  # Catalog list screen with search bar, category chips, and refresh
│   │       └── movie_detail_screen.dart # Detail screen with actors carousel, suggestions, and API inspector
│   └── main.dart                       # App bootstrap, .env loading, and Provider injection
├── test/
│   └── widget_test.dart                # Comprehensive unit and widget test suite (14 passing tests)
└── pubspec.yaml                        # Dependencies and configuration
```

---

## Screen Descriptions

### 1. Movie List Screen (`lib/presentation/screens/movie_list_screen.dart`)
- **Purpose**: Main landing view displaying popular, top rated, or trending movies with live search capabilities.
- **Components**:
  - Top AppBar with application title and quick-reload action.
  - Interactive search input with clear button hooked into the TMDB `/search/movie` endpoint.
  - Category filter chips (`🔥 Popular`, `⭐ Top Rated`, `📈 Trending`).
  - Interactive movie cards featuring poster images, title, star rating, release year, and synopsis.
  - Asynchronous feedback states: loading spinner indicator, error view with a **Try Again** retry button, and empty state handling.
  - Pull-to-refresh support (`RefreshIndicator`) for reloading content.
- **Flow**: Tapping any movie card selects that movie and navigates to the **Movie Detail Screen**.

### 2. Movie Detail Screen (`lib/presentation/screens/movie_detail_screen.dart`)
- **Purpose**: Displays detailed information, actor cast, and recommendations for the selected movie.
- **Components**:
  - 16:9 aspect-ratio movie backdrop banner with network fallback.
  - Movie title and marketing tagline.
  - Metadata badges displaying rating (`/ 10`), release date, runtime, and release status.
  - Complete plot overview synopsis.
  - **Top Cast & Actors Section**: Horizontal scrolling carousel with circular actor portraits, names, and character roles (`/movie/{id}/credits`).
  - **Suggested Movies Section**: Horizontal scrolling carousel of recommended movies with poster, rating, and title (`/movie/{id}/recommendations`). Tapping any suggested movie opens its detail screen.
  - **TMDB API Output Inspector**: Dedicated card displaying the actual parsed key-value properties directly from the API response (`ID`, `Title`, `Vote Average`, `Release Date`, `Actors Count`, `Suggested Count`, etc.).

---

## Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- Dart SDK installed

### 2. Configure Environment
Create a `.env` file in the `frontend` root directory with your TMDB API key:

```env
TMDB_API_KEY=your_tmdb_api_key_here
```

### 3. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 4. Run the Application
```bash
flutter run
```

### 5. Run Automated Tests
```bash
flutter test
```

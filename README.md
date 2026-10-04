# Navigations

**Owner:** Glenn Mykhel V. Gulfan  
**Group Members:**
- Glenn Mykhel V. Gulfan
- Jayshan Godornes
- Sean Cole Calixton
- Ranela Esgana

---

A modern Flutter mobile application demonstrating multi-screen architecture and seamless tab transitions using Flutter's `BottomNavigationBar` and `IndexedStack`. Built with Material 3 styling and clean separation of concerns, the app provides a smooth, state-preserving user experience across authentication, dashboards, profile management, and settings.

---

## Features

- **Authentication Flow:** Secure-style mock sign-in with prefilled credentials and route guards.
- **State-Preserving Tab Navigation:** Multi-screen shell using `IndexedStack` to preserve widget scroll and input state across tab switches.
- **Interactive Dashboard:** Metric summary counters (Projects, Tasks, Messages) and recent activity items.
- **User Profile Management:** Profile card with avatar, role information, contact metadata, and a one-tap logout action.
- **Reactive Settings:** Interactive preference controls with immediate UI state feedback (Dark Mode toggle, Notification alerts).
- **Test-Driven Reliability:** Comprehensive automated widget test suite validating full end-to-end navigation flows.

---

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (SDK `^3.13.3`) |
| **Language** | [Dart](https://dart.dev/) |
| **UI & Theming** | Material Design 3 (`ThemeData` with indigo seed palette) |
| **Icons** | Material Icons & Cupertino Icons |
| **Testing** | Flutter Test Framework (`flutter_test`) |
| **Automation** | PowerShell deterministic test scripts (`execution/run_tests.ps1`) |

---

## Project Structure

```text
navigations/
├── directives/
│   └── app_navigation_directive.md   # Architectural specifications and requirements
├── execution/
│   ├── INDEX.md                      # Tooling registry
│   └── run_tests.ps1                 # Deterministic test runner & analyzer script
├── lib/
│   ├── models/
│   │   └── app_data.dart             # Mock data models (UserProfile, MockStat)
│   ├── screens/
│   │   ├── dashboard_screen.dart     # Overview metrics & mock activity feed
│   │   ├── login_screen.dart         # Authentication entry point
│   │   ├── main_navigation_screen.dart # Bottom navigation shell with IndexedStack
│   │   ├── profile_screen.dart       # User details & session logout
│   │   └── settings_screen.dart      # Toggle preferences & application info
│   └── main.dart                     # App bootstrap, theming, and named routes
├── test/
│   ├── navigation_test.dart          # Automated navigation flow integration tests
│   └── widget_test.dart              # Base widget tests
└── pubspec.yaml                      # Project dependencies and configuration
```

---

## Screen Descriptions

### 1. Login Screen (`lib/screens/login_screen.dart`)
- **Purpose**: Serves as the authentication gateway for the app.
- **Components**: Branded lock icon header, email and password text fields with validation keys, and a prominent "Login" action button.
- **Flow**: Tapping "Login" replaces the current route with the main application shell (`/main`).

### 2. Main Navigation Shell (`lib/screens/main_navigation_screen.dart`)
- **Purpose**: Acts as the root container for authenticated tabs.
- **Components**: A persistent `BottomNavigationBar` fixed with three destinations: **Dashboard**, **Profile**, and **Setting**.
- **Flow**: Wraps pages in an `IndexedStack` to prevent rebuilding tabs on switch, maintaining scroll positions and widget states.

### 3. Dashboard Screen (`lib/screens/dashboard_screen.dart`)
- **Purpose**: High-level overview and landing tab upon authentication.
- **Components**:
  - Welcome greeting card ("Hello, Alex Mercer 👋").
  - Three-column metrics row displaying active Projects, Tasks, and Messages.
  - Recent activity card tracking completed and in-progress tasks.

### 4. Profile Screen (`lib/screens/profile_screen.dart`)
- **Purpose**: Displays user identity and account management options.
- **Components**:
  - User avatar, full name, professional title, and bio description.
  - Contact information card with email and phone tiles.
  - Highlighted **Log Out** button which clears the navigation stack and redirects back to the Login screen.

### 5. Settings Screen (`lib/screens/settings_screen.dart`)
- **Purpose**: Application preferences and general configurations.
- **Components**:
  - Interactive switches for **Dark Mode** and **Notifications**.
  - Informational tiles for application Language and Version (`1.0.0 (Mock)`).

---

## Demo App with Video

### Video Demonstration
`2026-09-29.19-49-11.mp4`

---

## Running the App Locally

To preview and record the application on an emulator or physical device:

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on an active emulator / connected device**:
   ```bash
   flutter run
   ```

3. **Execute automated verification tests**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ./execution/run_tests.ps1 -Analyze
   ```

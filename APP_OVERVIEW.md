# Curan — Quran Audio Player App

> **A secure, full-featured Quran audio player with biometric authentication, Firebase integration, prayer times, and Qibla compass.**

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Dependencies](#4-dependencies)
5. [Architecture](#5-architecture)
6. [App Flow](#6-app-flow)
7. [Screens & Features](#7-screens--features)
8. [Providers (State Management)](#8-providers-state-management)
9. [Services (Business Logic)](#9-services-business-logic)
10. [Data Models](#10-data-models)
11. [Routing & Navigation](#11-routing--navigation)
12. [Theme & Styling](#12-theme--styling)
13. [API Endpoints](#13-api-endpoints)
14. [Known Issues & TODOs](#14-known-issues--todos)

---

## 1. Project Overview

| Attribute | Value |
|-----------|-------|
| **Name** | `curan` |
| **Description** | A secure Quran audio player with biometric authentication and Firebase integration |
| **Version** | `1.0.0+1` |
| **SDK** | `^3.11.0` |
| **Platforms** | Android, iOS, Web, macOS, Windows, Linux |
| **State Management** | Provider (ChangeNotifier) |
| **Backend** | Firebase (Auth + Firestore) |

Curan lets users:
- Stream Quran audio from multiple renowned reciters (114 Surahs each)
- Lock the app with biometric authentication (fingerprint / Face ID)
- Track listening time with monthly goals and statistics charts
- Save favorites with biometric-protected removal
- View daily Islamic prayer times via GPS location
- Find Qibla direction using the device's magnetometer
- Search across surah names and reciter names
- Manage playlists with repeat, shuffle, and queue controls

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (3.x) |
| **Language** | Dart (^3.11) |
| **State Management** | Provider 6.x |
| **Auth** | Firebase Auth (email/password) |
| **Database** | Cloud Firestore |
| **Audio** | just_audio |
| **Location** | geolocator |
| **Sensors** | sensors_plus (magnetometer) |
| **Biometrics** | local_auth |
| **Charts** | fl_chart |
| **Local Storage** | shared_preferences |
| **HTTP** | http package |
| **Date/Time** | intl |
| **Linting** | flutter_lints |

---

## 3. Project Structure

```
quran-app-flutter/
├── curan/                              # Flutter project root
│   ├── lib/
│   │   ├── main.dart                   # Entry point, MultiProvider, MaterialApp
│   │   ├── firebase_options.dart        # Auto-generated Firebase config
│   │   │
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart   # App name, default values, sound paths
│   │   │   │   └── surah_names.dart     # List of 114 surah names
│   │   │   ├── routes/
│   │   │   │   └── app_routes.dart      # Route name constants
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart       # Dark premium theme with glassmorphism
│   │   │   └── utils/
│   │   │       └── validators.dart      # Email/password/name validation
│   │   │
│   │   ├── models/
│   │   │   ├── track_model.dart         # Track (surah) data model
│   │   │   ├── user_model.dart          # Firebase user profile model
│   │   │   ├── listening_stats.dart     # Listening statistics model
│   │   │   ├── playlist_category.dart   # Reciter playlist category model
│   │   │   └── prayer_times_model.dart  # Prayer times data model
│   │   │
│   │   ├── providers/
│   │   │   ├── auth_provider.dart       # Auth state, login/logout/signup
│   │   │   ├── audio_provider.dart      # Playback state, playlists, queue
│   │   │   ├── favorites_provider.dart  # Favorite tracks with biometric gate
│   │   │   ├── navigation_provider.dart # Bottom nav tab index
│   │   │   ├── prayer_times_provider.dart # Prayer times loading/state
│   │   │   └── stats_provider.dart      # Listening stats & monthly goal
│   │   │
│   │   ├── services/
│   │   │   ├── audio_api_service.dart   # mp3quran.net API client
│   │   │   ├── audio_player_service.dart # just_audio playback wrapper
│   │   │   ├── auth_service.dart        # Firebase Auth + Firestore user CRUD
│   │   │   ├── biometric_service.dart   # local_auth wrapper
│   │   │   ├── device_settings_service.dart # Platform channel for settings
│   │   │   ├── firestore_service.dart   # Firestore favorites + stats CRUD
│   │   │   └── prayer_times_service.dart # Aladhan API + GPS + caching
│   │   │
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── biometric/
│   │   │   │   └── biometric_setup_screen.dart
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_screen.dart   # Home with stats, goals, chart
│   │   │   ├── favorites/
│   │   │   │   └── favorites_screen.dart
│   │   │   ├── player/
│   │   │   │   └── player_screen.dart      # Library + Playlist tabs
│   │   │   ├── prayer_times/
│   │   │   │   └── prayer_times_screen.dart
│   │   │   ├── qibla/
│   │   │   │   └── qibla_compass_screen.dart
│   │   │   ├── search/
│   │   │   │   └── search_screen.dart
│   │   │   ├── settings/
│   │   │   │   └── settings_screen.dart
│   │   │   └── splash/
│   │   │       └── splash_screen.dart      # Animated splash + biometric gate
│   │   │
│   │   └── widgets/
│   │       ├── audio_player_widget.dart     # Full player controls UI
│   │       ├── histogram_chart.dart         # Monthly listening bar chart
│   │       ├── main_shell.dart              # Bottom nav shell (5 tabs)
│   │       ├── persistent_player_wrapper.dart # Route handler + mini-player
│   │       ├── reciter_avatar.dart          # Reciter circle avatar
│   │       └── track_list_item.dart         # Track row widget
│   │
│   └── test/
│       └── widget_test.dart
│
├── README.md
├── Curan_Presentation.pptx
├── make_pptx.py
└── presentation.html
```

---

## 4. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8            # iOS-style icons
  firebase_core: ^4.7.0              # Firebase initialization
  firebase_auth: ^6.4.0              # Email/password authentication
  cloud_firestore: ^6.2.0            # Firestore database
  provider: ^6.1.5                   # State management
  local_auth: ^3.0.1                 # Biometric authentication
  just_audio: ^0.9.46                # Audio playback
  fl_chart: ^1.1.1                   # Bar charts for stats
  http: ^1.5.0                       # HTTP client (APIs)
  shared_preferences: ^2.5.3         # Local key-value storage
  intl: ^0.20.2                      # Date formatting
  path_provider: ^2.1.5              # Filesystem paths
  geolocator: ^13.0.2                # GPS location
  sensors_plus: ^7.0.0              # Magnetometer for Qibla
```

---

## 5. Architecture

```
┌──────────────────────────────────────────────────┐
│  main.dart                                       │
│  ├── Firebase.initializeApp()                    │
│  ├── MultiProvider (6 ChangeNotifiers)           │
│  ├── TrackingInitializer (listening callbacks)   │
│  └── MaterialApp + onGenerateRoute               │
├──────────────────────┬───────────────────────────┤
│     Providers        │      Services             │
│   (ChangeNotifier)   │   (Business Logic)        │
├──────────────────────┼───────────────────────────┤
│ AuthProvider         │→ AuthService              │
│ AudioProvider        │→ AudioPlayerService       │
│                      │  AudioApiService          │
│ FavoritesProvider    │→ FirestoreService          │
│                      │  BiometricService          │
│ StatsProvider        │→ FirestoreService          │
│ PrayerTimesProvider  │→ PrayerTimesService        │
│ NavigationProvider   │  (built-in)                │
├──────────────────────┴───────────────────────────┤
│         Screens → Widgets → Models               │
└──────────────────────────────────────────────────┘
```

**Pattern:** Provider-based MVVM
- **Models** — Data classes with serialization (`toMap`/`fromMap`)
- **Providers** — ViewModels that extend `ChangeNotifier`, consumed by UI via `Consumer`/`context.watch`
- **Services** — Stateless business logic classes
- **Screens/Widgets** — UI layer that calls providers and builds widgets

---

## 6. App Flow

```
SplashScreen
  │
  ├── Biometric available? ──No──→ "Enable Biometric" dialog → Open Settings
  │
  ├── Biometric authenticates? ──No──→ Retry dialog → exit app
  │
  └── Biometric success
         │
    AuthWrapper (Consumer<AuthProvider>)
         │
    ┌────┴────┐
    │         │
  Not logged Logged in
    │         │
 LoginScreen MainShell (IndexedStack, 5 tabs)
                │
           ┌────┼────┬────┬────┐
          Home Player Favorites Prayer Settings
                │
       Mini-player (persistent above nav bar)
```

---

## 7. Screens & Features

### Splash Screen
- Animated logo with fade-in + scale transition
- Biometric authentication gate (fingerprint / Face ID)
- Mandatory biometric enrollment if device has no biometrics configured

### Login Screen
- Email/password form with validation
- link to Register, Forgot Password

### Register Screen
- Fields: First Name, Last Name, Email, Date of Birth, Password, Confirm Password
- All fields validated; `DateOfBirth` uses `showDatePicker`

### Forgot Password Screen
- Email input → Firebase password reset email

### Biometric Setup Screen
- Optional post-login screen to enable/confirm biometric unlock

### Dashboard (Home)
- Welcome strip with user name + total listening time
- Quick action tiles (Search, Player, Favorites, Prayer Times, Qibla)
- Monthly goal progress bar (configurable in Settings)
- Histogram chart (fl_chart) showing daily listening minutes for current month
- Top listened tracks section

### Player Screen
- Two tabs: **Library** (all categories) and **Playlist** (current queue)
- Bottom sheet category/reciter selector
- Full audio controls: play/pause, next/prev, seek bar, repeat (off/all/one), shuffle
- Track list with play indicators and favorite toggle per item
- Favorites toggle heart button per track

### Favorites Screen
- List of saved favorite tracks
- Play a favorite directly
- Remove a favorite → triggers biometric authentication first (protected action)

### Prayer Times Screen
- GPS location detection
- Fetches daily prayer times from Aladhan API (ISNA method)
- Displays: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
- Highlights the **next upcoming prayer**
- Shows Hijri date alongside Gregorian date
- City name display
- Results cached in SharedPreferences

### Qibla Compass Screen
- Magnetometer-based compass using `sensors_plus`
- Calculates Qibla direction from current GPS coordinates
- Smooth heading filtering for stable readings
- Alignment animation when facing Kaaba

### Search Screen
- Text search across all surah names and reciter names
- Results display matching tracks with play action

### Settings Screen
- View/edit profile (First Name, Last Name, Email)
- Monthly listening goal slider (1–60 hours)
- Biometric lock toggle
- Change password
- Delete account (with confirmation)
- App version display
- Sign out

---

## 8. Providers (State Management)

All registered in `MultiProvider` at the app root.

| Provider | File | Key Responsibilities |
|----------|------|---------------------|
| `AuthProvider` | `auth_provider.dart` | Firebase auth state, login/signup/signout, password reset, profile update, delete account, loading/error state |
| `AudioProvider` | `audio_provider.dart` | Playlist categories, current playlist, current track index, playback position/duration, playing/paused, repeat mode, shuffle, `init()` loads audio API data |
| `FavoritesProvider` | `favorites_provider.dart` | Favorites list (from Firestore stream), `toggleFavorite()` with biometric check, `isFavorite()` check |
| `StatsProvider` | `stats_provider.dart` | `ListeningStats` object, `recordListening()` method, monthly goal progress calculation, load stats from Firestore |
| `PrayerTimesProvider` | `prayer_times_provider.dart` | Current `PrayerTimesModel`, loading/error state, `fetchPrayerTimes()` |
| `NavigationProvider` | `navigation_provider.dart` | Tab index (0–4), convenience methods: `goToHome()`, `goToPlayer()`, `goToFavorites()`, `goToPrayerTimes()`, `goToSettings()` |

---

## 9. Services (Business Logic)

| Service | File | Details |
|---------|------|---------|
| `AuthService` | `auth_service.dart` | `signUp()`, `signIn()`, `signOut()`, `resetPassword()`, `updateProfile()`, `deleteAccount()` — all via Firebase Auth. Also creates/updates user documents in Firestore `users/` collection and creates initial stats document. |
| `AudioApiService` | `audio_api_service.dart` | Fetches `https://www.mp3quran.net/api/v3/reciters?language=eng`, parses reciters with moshaf/surah lists, builds `PlaylistCategory` objects. Falls back to 2 hardcoded reciters (Mishary Al-Afasy, Sudais) on failure. |
| `AudioPlayerService` | `audio_player_service.dart` | Wraps `just_audio` `AudioPlayer`. Methods: `load()`, `play()`, `pause()`, `seek()`, `next()`, `previous()`, `setRepeatMode()`, `toggleShuffle()`. Tracks listening duration and fires a callback on track completion. |
| `BiometricService` | `biometric_service.dart` | `isAvailable()` (checks device biometric support), `authenticate()` (shows system biometric prompt), `authenticateForSensitiveAction()` (scoped auth for favorites removal). |
| `FirestoreService` | `firestore_service.dart` | Favorites CRUD with realtime stream (`favorites/{userId}/items/{trackId}`). Stats recording via batch writes (daily/monthly nested maps + top tracks subcollection). `getListeningStats()` reads and aggregates data. |
| `PrayerTimesService` | `prayer_times_service.dart` | Gets GPS location via `geolocator`, calls `https://api.aladhan.com/v1/timings` (method 2 = ISNA), parses JSON to `PrayerTimesModel`. Caches latest result in `SharedPreferences`. |
| `DeviceSettingsService` | `device_settings_service.dart` | Opens device security settings via platform `MethodChannel('com.example.curan/settings')`. |

---

## 10. Data Models

### TrackModel
```dart
class TrackModel {
  final String id;
  final String title;
  final String audioUrl;
  String? category;      // Reciter name
  int? duration;         // seconds
  int? trackNumber;      // surah number
}
```

### UserModel
```dart
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime dateOfBirth;
  final DateTime createdAt;
}
```

### ListeningStats
```dart
class ListeningStats {
  Duration totalListeningTime;
  Map<DateTime, int> monthlyListening; // day-of-month → minutes
  List<TrackPlayCount> topTracks;
}

class TrackPlayCount {
  final String trackId;
  final String trackTitle;
  int playCount;
  Duration totalListened;
}
```

### PlaylistCategory
```dart
class PlaylistCategory {
  final String id;        // reciter ID
  final String name;      // reciter name
  final List<TrackModel> tracks;
}
```

### PrayerTimesModel
```dart
class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;         // Gregorian
  final String hijriDate;
  final String city;
}
```

---

## 11. Routing & Navigation

The app uses a **dual navigation system**:

### Global Navigator (`onGenerateRoute` in `main.dart`)
Standard `MaterialPageRoute` pushes for full-screen transitions:

| Route Name | Screen |
|------------|--------|
| `/` (splash) | `SplashScreen` |
| `/authWrapper` | `AuthWrapper` (auth gate) |
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` |
| `/forgot-password` | `ForgotPasswordScreen` |
| `/biometric-setup` | `BiometricSetupScreen` |
| `/dashboard` | `DashboardScreen` |
| `/player` | `PlayerScreen` |
| `/favorites` | `FavoritesScreen` |
| `/settings` | `SettingsScreen` |
| `/prayer-times` | `PrayerTimesScreen` |
| `/search` | `SearchScreen` |
| `/qibla` | `QiblaCompassScreen` |

### Bottom Tab Navigation (MainShell)
`IndexedStack` with `NavigationProvider` (no route pushes, just tab index switching):
- 0: Dashboard (Home)
- 1: Player
- 2: Favorites
- 3: Prayer Times
- 4: Settings

### Persistent Player Wrapper
`PersistentPlayerWrapper` wraps all routes and renders a persistent mini-player floating above the bottom nav bar.

---

## 12. Theme & Styling

**Type:** Dark theme only (uses `Brightness.dark` themed as `ThemeData.light()` with dark colors)

| Token | Value |
|-------|-------|
| **Primary** | `#00BFA6` (Teal/emerald green) |
| **Secondary** | `#1A237E` (Deep indigo) |
| **Tertiary** | `#64FFDA` (Bright mint) |
| **Background** | `#090E1A` (Deep navy-black) |
| **Surface** | `#111827` / `#1F2937` (Dark cards) |
| **Error** | `#FF5370` (Red) |
| **Material 3** | Enabled |

**Visual Style:**
- Glassmorphism effects via `BackdropFilter` blur
- Gradient accents and ambient glow orbs
- Rounded corners (12–14px) on cards, inputs, buttons
- Full-width elevated buttons with teal fill
- Input fields: rounded (14px), filled with `surface2`, teal focus border
- Typography: 9 text styles (displayLarge → labelLarge), all white-based

---

## 13. API Endpoints

| API | URL | Purpose | Method |
|-----|-----|---------|--------|
| mp3quran.net | `https://www.mp3quran.net/api/v3/reciters?language=eng` | Fetch reciters & surah lists | GET |
| Audio stream | `https://server8.mp3quran.net/afs/{nnn}.mp3` | Mishary Al-Afasy audio | GET |
| Audio stream | `https://server11.mp3quran.net/sds/{nnn}.mp3` | Sudais audio | GET |
| Aladhan Prayer | `https://api.aladhan.com/v1/timings?latitude=...&longitude=...&method=2` | Daily prayer times (ISNA) | GET |
| UI Avatars | `https://ui-avatars.com/api/?name=...` | Reciter avatar fallback images | GET |

---

## 14. Known Issues & TODOs

1. **Missing asset file** — `AppConstants` references `assets/sounds/success.mp3` but the `assets/sounds/` directory is empty.
2. **Dual navigation inconsistency** — `onGenerateRoute` in `main.dart` duplicates route handling present in `PersistentPlayerWrapper`, which can cause confusion.
3. **No offline audio** — All audio is streamed from internet URLs; no download/caching support.
4. **Biometric gate at splash** — If biometrics are unavailable or unconfigured, the user gets stuck in a dialog loop with only "Open Settings" as an option.
5. **NavigationProvider tab indices hardcoded** — 0=Home, 1=Player, 2=Favorites, 3=Prayer, 4=Settings; fragile if tabs are reordered.
6. **`withValues(alpha:)` vs `withOpacity()`** — Mixed usage of newer Dart `Color.withValues` and legacy `withOpacity` across the codebase.
7. **Stats data model** — `dailyListening` field in Firestore is tracked but `getListeningStats` aggregates it into monthly, creating potential data duplication.
8. **Minimal test coverage** — Only one widget test (app builds without crashing). No unit tests for providers, services, or models.

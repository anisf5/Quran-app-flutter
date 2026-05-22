# ChatGPT Prompt for PowerPoint Presentation

Copy and paste the entire prompt below into ChatGPT to generate presentation text for the Curan app.

---

```
I need to create a PowerPoint presentation for a Flutter mobile app called "Curan" — a secure Quran audio player. Generate structured presentation text for each slide below. For each slide, provide:
1. A concise slide title
2. 3–5 bullet points of speaker notes / slide content (professional, persuasive, demo-ready)
3. Optional: suggested visual (e.g., screenshot, icon, diagram)

Make it suitable for a technical project presentation (e.g., university capstone, portfolio showcase, or startup pitch). The tone should be confident and polished.

---

## APP OVERVIEW

**App Name:** Curan  
**Tagline:** A secure Quran audio player with biometric authentication and Firebase integration.  
**Tech Stack:** Flutter, Dart 3.11, Provider (state management), Firebase Auth + Firestore, just_audio, local_auth, fl_chart, geolocator, sensors_plus  
**Platforms:** Android, iOS, Web, macOS, Windows, Linux  

## FEATURES (10 screens)

1. **Splash Screen** — Animated logo with fade-in + biometric gate (fingerprint / Face ID)
2. **Login / Register / Forgot Password** — Firebase email/password auth with full validation
3. **Dashboard (Home)** — Welcome strip, total listening time, monthly goal progress bar, histogram chart of daily listening minutes, top tracks, quick action tiles
4. **Player Screen** — Two tabs (Library / Playlist), category & reciter selector bottom sheet, play/pause/next/prev/seek, repeat (off/all/one), shuffle, favorite toggle per track
5. **Favorites Screen** — List of favorited tracks, play from favorites, biometric-protected removal
6. **Prayer Times Screen** — GPS-based location, Aladhan API prayer times (ISNA method), next prayer highlight, Hijri date, cached results
7. **Qibla Compass Screen** — Magnetometer-based compass, GPS-based Qibla direction calculation, smooth heading filter, alignment animation
8. **Search Screen** — Full-text search across 114 surah names and multiple reciters
9. **Settings Screen** — Profile editor, monthly goal slider (1–60 hrs), biometric toggle, change password, delete account, sign out
10. **Biometric Setup Screen** — Optional biometric enrollment post-login

## ARCHITECTURE

- **Pattern:** Provider-based MVVM (Model-View-ViewModel)
- **Providers (6):** AuthProvider, AudioProvider, FavoritesProvider, StatsProvider, PrayerTimesProvider, NavigationProvider
- **Services (7):** AuthService, AudioApiService, AudioPlayerService, BiometricService, FirestoreService, PrayerTimesService, DeviceSettingsService
- **Data:** Firebase Firestore for users, favorites, and listening stats; SharedPreferences for local cache
- **APIs:** mp3quran.net (reciter/surah data), Aladhan API (prayer times), UI Avatars (reciter images)
- **Theme:** Premium dark theme with glassmorphism, teal primary (#00BFA6), Material 3

## KNOWN HIGHLIGHTS TO MENTION

- Biometric gate at app launch for security
- Listening analytics with histogram charts and monthly goals
- Dual navigation: bottom tabs + full-screen routes with persistent mini-player
- Cross-platform support (6 platforms)
- Islamic utilities: prayer times + Qibla compass
- 2 default reciters: Mishary Al-Afasy and Sudais (expandable via API)

---

## REQUESTED SLIDES

Generate content for the following slides — write each as a separate slide block:

1. **Title Slide** — "Curan: Secure Quran Audio Player" with subtitle, name, date
2. **Problem Statement** — Why this app exists (listening to Quran securely, tracking progress, Islamic tools in one place)
3. **Solution / Features Overview** — Key features at a glance (bullet grid)
4. **Tech Stack** — Flutter, Firebase, Provider, just_audio, etc. (visual grid)
5. **Architecture Diagram** — Explain the provider-service-model pattern
6. **User Flow / App Navigation** — Splash → Biometric → Auth → Main Shell → 5 tabs
7. **Dashboard & Analytics** — Listening stats, goals, chart
8. **Audio Player Experience** — Library, playlist, controls, reciter selection
9. **Security & Biometrics** — App lock, protected actions (favorites removal)
10. **Islamic Utilities** — Prayer times, Qibla compass, Hijri date
11. **Settings & Profile Management** — Profile editing, goal setting, account management
12. **Cross-Platform & Deployment** — 6 platforms, Firebase backend
13. **Future Roadmap** — offline audio downloads, more reciters, dark/light themes, notifications for prayer times, social features
14. **Demo / Walkthrough** — Suggested demo flow (launch → biometric → home → play surah → check prayer times → Qibla → settings)
15. **Thank You / Q&A** — Contact info, GitHub link

Return the content as plain text formatted for easy copy-paste into PowerPoint slides.
```

---

Paste the output from ChatGPT into your PowerPoint slides. Each slide block will have a title and bullet points ready to use.

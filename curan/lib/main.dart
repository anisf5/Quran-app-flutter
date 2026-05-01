import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/prayer_times_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/biometric/biometric_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/player/player_screen.dart';
import 'screens/prayer_times/prayer_times_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/persistent_player_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  runApp(const CuranApp());
}

class CuranApp extends StatelessWidget {
  const CuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()..init()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
      ],
      child: TrackingInitializer(
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const PersistentPlayerWrapper(),
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case '/authWrapper':
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case AppRoutes.biometricSetup:
        return MaterialPageRoute(
          builder: (_) => const BiometricSetupScreen(),
          settings: settings,
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case AppRoutes.player:
        return MaterialPageRoute(
          builder: (_) => const PlayerScreen(),
          settings: settings,
        );
      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.prayerTimes:
        return MaterialPageRoute(
          builder: (_) => const PrayerTimesScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}

class TrackingInitializer extends StatefulWidget {
  final Widget child;

  const TrackingInitializer({super.key, required this.child});

  @override
  State<TrackingInitializer> createState() => _TrackingInitializerState();
}

class _TrackingInitializerState extends State<TrackingInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTracking();
    });
  }

  void _setupTracking() {
    final audioProvider = context.read<AudioProvider>();
    final statsProvider = context.read<StatsProvider>();
    final authProvider = context.read<AuthProvider>();

    audioProvider.setOnTrackListened((track, duration) {
      final userId = authProvider.currentUser?.uid;
      if (userId != null) {
        statsProvider.recordListening(
          userId: userId,
          duration: duration,
          track: track,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}

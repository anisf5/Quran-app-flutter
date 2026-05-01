import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../screens/player/player_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/biometric/biometric_setup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/prayer_times/prayer_times_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'audio_player_widget.dart';

class PersistentPlayerWrapper extends StatefulWidget {
  const PersistentPlayerWrapper({super.key});

  @override
  State<PersistentPlayerWrapper> createState() => _PersistentPlayerWrapperState();
}

class _PersistentPlayerWrapperState extends State<PersistentPlayerWrapper> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Persistent audio player at top with better visibility
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Consumer<AudioProvider>(
              builder: (context, audio, _) {
                if (audio.currentTrack == null) {
                  return const SizedBox.shrink();
                }
                return Material(
                  elevation: 8,
                  color: Theme.of(context).cardColor,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: AudioPlayerWidget(
                        track: audio.currentTrack!,
                        position: audio.position,
                        duration: audio.duration,
                        isPlaying: audio.isPlaying,
                        isRepeat: audio.isRepeat,
                        isShuffled: audio.isShuffled,
                        onPlayPause: audio.togglePlayPause,
                        onSeek: audio.seekTo,
                        onNext: audio.seekToNext,
                        onPrevious: audio.seekToPrevious,
                        onToggleRepeat: audio.toggleRepeat,
                        onToggleShuffle: audio.toggleShuffle,
                        progress: audio.playbackProgress,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content with top padding for audio player
          Positioned.fill(
            top: 0,
            child: Consumer<AudioProvider>(
              builder: (context, audio, _) {
                final hasPlayer = audio.currentTrack != null;
                return Padding(
                  padding: EdgeInsets.only(
                    top: hasPlayer ? 140 : 0,
                  ),
                  child: Navigator(
                    key: _navigatorKey,
                    onGenerateRoute: (settings) {
                      return _getRoute(settings);
                    },
                    initialRoute: '/splash',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Route<dynamic>? _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case '/forgotPassword':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case '/biometricSetup':
        return MaterialPageRoute(
          builder: (_) => const BiometricSetupScreen(),
          settings: settings,
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case '/player':
        return MaterialPageRoute(
          builder: (_) => const PlayerScreen(),
          settings: settings,
        );
      case '/favorites':
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case '/prayerTimes':
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

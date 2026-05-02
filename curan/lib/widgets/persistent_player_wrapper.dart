import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/biometric/biometric_setup_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'main_shell.dart';

/// Root widget that hosts the navigator. All main (authenticated) screens are
/// rendered inside [MainShell] which owns the bottom navigation bar and the
/// floating mini-player. Auth/Splash screens navigate separately.
class PersistentPlayerWrapper extends StatefulWidget {
  const PersistentPlayerWrapper({super.key});

  @override
  State<PersistentPlayerWrapper> createState() =>
      _PersistentPlayerWrapperState();
}

class _PersistentPlayerWrapperState extends State<PersistentPlayerWrapper> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: _getRoute,
      initialRoute: '/splash',
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
      // All authenticated main screens are now handled by MainShell
      case '/dashboard':
      case '/player':
      case '/favorites':
      case '/settings':
      case '/prayerTimes':
      case '/main':
        return MaterialPageRoute(
          builder: (_) => const MainShell(),
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../services/biometric_service.dart';
import '../../services/device_settings_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final BiometricService _biometricService = BiometricService();
  final DeviceSettingsService _settingsService = DeviceSettingsService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _runStartupSequence();
      }
    });
  }

  Future<void> _runStartupSequence() async {
    final prefs = await SharedPreferences.getInstance();
    final wasPreviouslySetup =
        prefs.getBool(AppConstants.biometricSetupKey) ?? false;

    if (!wasPreviouslySetup) {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _showRequireBiometricDialog();
        return;
      }
      final success = await _biometricService.authenticate(
        reason: 'Authenticate to access Curan',
      );
      if (success) {
        await prefs.setBool(AppConstants.biometricSetupKey, true);
        _navigateToAuthWrapper();
      } else {
        _showRetryDialog();
        return;
      }
      return;
    }

    final isAvailable = await _biometricService.isBiometricAvailable();

    if (!isAvailable) {
      _showRequireBiometricDialog();
      return;
    }

    final success = await _biometricService.authenticate(
      reason: 'Authenticate to access Curan',
    );

    if (success) {
      _navigateToAuthWrapper();
    } else {
      _showRetryDialog();
    }
  }

  void _showRequireBiometricDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Biometric Required',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This app requires fingerprint or Face ID to protect your privacy. '
          'Please set up biometric authentication in your device settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _settingsService.openSecuritySettings();
              _runStartupSequence();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Authentication Required',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You must authenticate to use the app. Please try again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _runStartupSequence();
            },
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAuthWrapper() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/authWrapper');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 100,
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'CURAN',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your spiritual journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.tealAccent,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

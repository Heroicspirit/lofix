import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:musicapp/features/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreens extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const SplashScreens({super.key});

  @override
  ConsumerState<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends ConsumerState<SplashScreens> {
  // Changed to ConsumerState
  @override
  void initState() {
    super.initState();
    // Start the navigation timer
    _navigateToNext();
  }

  /// Handles the delayed navigation to the onboarding screen
  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    //check if the user is logged in
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }else {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lofix',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
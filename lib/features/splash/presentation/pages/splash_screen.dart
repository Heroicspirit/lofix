import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:musicapp/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';

class SplashScreens extends ConsumerStatefulWidget {

  const SplashScreens({super.key});

  @override
  ConsumerState<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends ConsumerState<SplashScreens> {

  @override
  void initState() {
    super.initState();

    _navigateToNext();
  }


  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();
    final isOnboardingCompleted = userSessionService.isOnboardingCompleted();

    print('=== DEBUG: Splash Screen Navigation ===');
    print('isLoggedIn: $isLoggedIn');
    print('isOnboardingCompleted: $isOnboardingCompleted');

    // Navigation Logic:
    // 1. If onboarding never completed -> Show onboarding
    // 2. If onboarding completed but logged out -> Show login
    // 3. If onboarding completed and logged in -> Show dashboard
    
    if (!isOnboardingCompleted) {
      // First time user or onboarding not completed
      print('Navigating to Onboarding Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (isLoggedIn) {
      // Onboarding completed and user is logged in
      print('Navigating to Dashboard Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Onboarding completed but user is logged out
      print('Navigating to Login Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
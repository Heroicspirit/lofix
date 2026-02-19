import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/foundation.dart';

class ScreenWrapper extends ConsumerWidget {
  final Widget child;

  const ScreenWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: () {
        if (kDebugMode) {
          print('Double-tap detected! Toggling theme.');
        }
        themeNotifier.toggleTheme();
      },
      onLongPress: () async {
        if (kDebugMode) {
          print('Long-press detected! Logging out.');
        }
        final userSessionService = ref.read(userSessionServiceProvider);
        await userSessionService.logout();
        
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SplashScreens()),
            (route) => false,
          );
        }
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

class SensorGestureDetector extends ConsumerStatefulWidget {
  final Widget child;

  const SensorGestureDetector({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SensorGestureDetector> createState() => _SensorGestureDetectorState();
}

class _SensorGestureDetectorState extends ConsumerState<SensorGestureDetector> {
  var _accelerometerSubscription;
  bool _isShaking = false;
  DateTime? _lastShakeTime;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _initShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _initShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      final double acceleration = (event.x.abs() + event.y.abs() + event.z.abs()) / 3;
      final DateTime now = DateTime.now();

      if (acceleration > 12) {
        if (_lastShakeTime == null || 
            now.difference(_lastShakeTime!).inMilliseconds > 1000) {
          _lastShakeTime = now;
          if (!_isShaking) {
            _isShaking = true;
            _handleShake();
            Future.delayed(const Duration(seconds: 2), () {
              _isShaking = false;
            });
          }
        }
      }
    });
  }

  void _handleShake() async {
    print('Shake detected! Starting logout process...');
    try {
      final userSessionService = ref.read(userSessionServiceProvider);
      await userSessionService.logout();
      print('Logout completed successfully');
      
      // Use a more reliable navigation approach
      if (mounted) {
        print('Navigating to login screen...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
            print('Navigation completed');
          }
        });
      } else {
        print('Widget not mounted, cannot navigate');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        final now = DateTime.now();
        if (_lastTapTime != null) {
          final timeSinceLastTap = now.difference(_lastTapTime!);
          if (timeSinceLastTap.inMilliseconds < 300) {
            // Double tap detected
            if (kDebugMode) {
              print('Double tap detected!');
            }
            themeNotifier.toggleTheme();
            _lastTapTime = null; // Reset to avoid triple tap
          } else {
            _lastTapTime = now;
          }
        } else {
          _lastTapTime = now;
        }
      },
      child: widget.child,
    );
  }
}

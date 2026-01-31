import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart'; // Ensure this is imported
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/home_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';

// 1. Refined Mock: Notifiers need a valid build() return for the UI to render initially
class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState.initial(); 
}

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockUserSessionService mockSessionService;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockSessionService = MockUserSessionService();
    mockAuthViewModel = MockAuthViewModel();

    // 2. Stubbing Session Service
    when(() => mockSessionService.getUsername()).thenReturn("Test User");
    when(() => mockSessionService.getUserEmail()).thenReturn("test@example.com");
    when(() => mockSessionService.getUserProfileImage()).thenReturn(null);
  });

  Widget createDashboardScreen() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockSessionService),
        // Use overrideWith for Notifiers
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group("DashboardScreen Navigation Tests", () {
    testWidgets('Initial screen should be HomeScreen', (tester) async {
      await tester.pumpWidget(createDashboardScreen());
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Tapping Profile icon navigates to ProfileScreen and shows user info', (tester) async {
      await tester.pumpWidget(createDashboardScreen());

      // 3. Finding by Icon is great, but ensure it's specifically the Nav Bar icon
      final profileTab = find.byIcon(Icons.person);
      await tester.tap(profileTab);
      await tester.pumpAndSettle(); 

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text("Test User"), findsOneWidget);
    });
    
    testWidgets('Navigation bar has correct styling', (tester) async {
      await tester.pumpWidget(createDashboardScreen());
      
      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.backgroundColor, Colors.amber);
      expect(navBar.selectedItemColor, Colors.blueAccent);
    });
  });
}
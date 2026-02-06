import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/home_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';

// 1. Create Mock classes
class MockUserSessionService extends Mock implements UserSessionService {}
class MockAuthViewModel extends AuthViewModel with Mock {} 

void main() {
  late MockUserSessionService mockSessionService;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockSessionService = MockUserSessionService();
    mockAuthViewModel = MockAuthViewModel();

    // 2. Stub the methods that ProfileScreen calls during its build/init
    when(() => mockSessionService.getUsername()).thenReturn("Test User");
    when(() => mockSessionService.getUserEmail()).thenReturn("test@example.com");
    when(() => mockSessionService.getUserProfileImage()).thenReturn(null);
  });

  Widget createDashboardScreen() {
    return ProviderScope(
      overrides: [
        // 3. Override the providers that cause the SharedPreferences error
        userSessionServiceProvider.overrideWithValue(mockSessionService),
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

      // Tap on the Profile item
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle(); // Wait for navigation animation

      // Verify ProfileScreen is shown
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      // Verify that the mocked data is visible on the screen
      expect(find.text("Test User"), findsOneWidget);
    });
    
    testWidgets('Navigation bar has correct background color', (tester) async {
      await tester.pumpWidget(createDashboardScreen());
      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.backgroundColor, Colors.amber);
    });
  });
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';

class MockUserSessionService extends Mock implements UserSessionService {}
class MockOfflineModeNotifier extends StateNotifier<OfflineModeState> implements OfflineModeNotifier {
  MockOfflineModeNotifier() : super(OfflineModeState(
    status: OfflineModeStatus.online,
    isLoggedIn: false,
    hasNetwork: true,
  ));
  
  @override
  Future<void> checkConnectionStatus() async {}
  
  @override
  Future<void> refresh() async {}
  
  @override
  void updateLoginStatus(bool isLoggedIn) {}
}

class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel();

  bool logoutCalled = false;

  @override
  AuthState build() => AuthState.initial();

  @override
  Future<void> register({required String email, required String name, required String password,String? confirmPassword}) async {
    // no-op for tests
  }

  @override
  Future<void> login({required String email, required String password}) async {
    // no-op for tests
  }

  @override
  Future<void> getCurrentUser() async {
    // no-op for tests
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = AuthState.initial();
  }

  @override
  Future<void> uploadPhoto(File photo) async {
    // no-op for tests
  }

  @override
  void resetState() {
    state = AuthState.initial();
  }

  @override
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

void main() {
  late TestAuthViewModel mockAuthViewModel;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockAuthViewModel = TestAuthViewModel();
    mockUserSessionService = MockUserSessionService();
    
    // Mock user session service methods
    when(() => mockUserSessionService.getUsername()).thenReturn("Test User");
    when(() => mockUserSessionService.getUserEmail()).thenReturn("test@example.com");
    when(() => mockUserSessionService.getUserProfileImage()).thenReturn(null);
    
    // Initialize mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createProfileScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        offlineModeProvider.overrideWith((ref) => MockOfflineModeNotifier()),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen UI Tests', () {
    testWidgets('ProfileScreen displays user information', (WidgetTester tester) async {
      await tester.pumpWidget(await createProfileScreen());
      await tester.pump();

      // Check for user name and email
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget); // AppBar title
    });

    testWidgets('ProfileScreen has logout button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(await createProfileScreen());
      await tester.pump();

      // Verify logout icon exists in AppBar
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('ProfileScreen shows settings sections', (WidgetTester tester) async {
      await tester.pumpWidget(await createProfileScreen());
      await tester.pump();

      // Check for settings sections
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Favorite Songs'), findsOneWidget);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About App'), findsOneWidget);
    });

    testWidgets('Logout button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(await createProfileScreen());
      await tester.pump();

      final logoutFinder = find.byIcon(Icons.logout);
      expect(logoutFinder, findsOneWidget);

      // Just verify the button can be tapped without checking the logout logic
      await tester.tap(logoutFinder);
      await tester.pump(); // Process the tap
      
      // Test passes if no exceptions are thrown during tap
      expect(logoutFinder, findsOneWidget);
    });
  });
}
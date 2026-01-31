import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';


// Mocking the services
class MockUserSessionService extends Mock implements UserSessionService {}
class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState.initial(); // Crucial for Riverpod 2.0
}
void main() {
  late MockUserSessionService mockSessionService;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockSessionService = MockUserSessionService();
    mockAuthViewModel = MockAuthViewModel();

    // Stubbing default behaviors for the user session
    when(() => mockSessionService.getUsername()).thenReturn("John Doe");
    when(() => mockSessionService.getUserEmail()).thenReturn("john@example.com");
    when(() => mockSessionService.getUserProfileImage()).thenReturn(null);
  });

  Widget createProfileScreen() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockSessionService),
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group("ProfileScreen Widget Tests", () {
    testWidgets('Displays user information from UserSessionService', (tester) async {
      await tester.pumpWidget(createProfileScreen());

      // Assert: Check if Name and Email appear on screen
      expect(find.text("John Doe"), findsOneWidget);
      expect(find.text("john@example.com"), findsOneWidget);
      // Assert: Check if first letter 'J' is shown in CircleAvatar since image is null
      expect(find.text("J"), findsOneWidget);
    });

    testWidgets('Tapping logout icon calls authViewModel.logout()', (tester) async {
      await tester.pumpWidget(createProfileScreen());

      // Act: Find and tap the logout button
      final logoutButton = find.byIcon(Icons.logout);
      await tester.tap(logoutButton);
      await tester.pump();

      // Assert: Verify the method was called
      verify(() => mockAuthViewModel.logout()).called(1);
    });

    testWidgets('Tapping camera icon opens BottomSheet with Camera/Gallery options', (tester) async {
      await tester.pumpWidget(createProfileScreen());

      // Act: Tap the camera icon
      final cameraIcon = find.byIcon(Icons.camera_alt);
      await tester.tap(cameraIcon);
      await tester.pumpAndSettle(); // Wait for animation

      // Assert: Verify BottomSheet options are visible
      expect(find.text("Camera"), findsOneWidget);
      expect(find.text("Gallery"), findsOneWidget);
    });

    testWidgets('Displays Settings sections correctly', (tester) async {
      await tester.pumpWidget(createProfileScreen());

      // Assert: Verify section titles exist
      expect(find.text("Account Settings"), findsOneWidget);
      expect(find.text("Preferences"), findsOneWidget);
      expect(find.text("Edit Profile"), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
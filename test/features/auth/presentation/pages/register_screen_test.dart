import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:musicapp/features/auth/presentation/pages/register_screen.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';

// 1. Mock class extending the real ViewModel to satisfy Riverpod plumbing
class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState.initial();

  // Masking the real method to avoid LateInitializationError on usecases
  @override
  Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {}

  void emit(AuthState newState) {
    state = newState;
  }
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
  });

  Widget createRegisterScreen() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group("RegisterScreen Widget Tests", () {
    testWidgets('Should show error snackbar when validation fails (empty fields)', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final signUpButton = find.widgetWithText(ElevatedButton, "Sign Up");

      // FIX: Scroll to the button before tapping
      await tester.ensureVisible(signUpButton);
      await tester.pumpAndSettle();

      await tester.tap(signUpButton);
      await tester.pump(); // Start SnackBar animation

      expect(find.text("Please fill all fields"), findsOneWidget);
    });

    testWidgets('Should show error if passwords do not match', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Fill fields
      await tester.enterText(find.byType(TextField).at(0), "test@user.com");
      await tester.enterText(find.byType(TextField).at(1), "password123");
      await tester.enterText(find.byType(TextField).at(2), "wrongpassword");

      // Select Gender from Dropdown
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      final signUpButton = find.widgetWithText(ElevatedButton, "Sign Up");
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text("Passwords do not match!"), findsOneWidget);
    });

    testWidgets('Successful registration shows snackbar and navigates to Login', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Fill valid data
      await tester.enterText(find.byType(TextField).at(0), "newuser@test.com");
      await tester.enterText(find.byType(TextField).at(1), "Password123");
      await tester.enterText(find.byType(TextField).at(2), "Password123");

      // Select Gender
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();

      // Stub the register call
      when(() => mockAuthViewModel.register(
            email: "newuser@test.com",
            name: "newuser",
            password: "Password123",
          )).thenAnswer((_) async {});

      final signUpButton = find.widgetWithText(ElevatedButton, "Sign Up");
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);

      // Trigger the "registered" state manually
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.registered));
      
      await tester.pumpAndSettle(); // Wait for navigation and snackbar

      expect(find.text("Account Created! Please Login"), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Shows CircularProgressIndicator when status is loading', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Trigger loading state
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.loading));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final signUpButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(signUpButton.onPressed, isNull); // Verify button is disabled
    });
  });
}
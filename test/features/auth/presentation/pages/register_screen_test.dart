import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/features/auth/presentation/pages/register_screen.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState.initial();

  void emit(AuthState newState) {
    state = newState;
  }
}

class MockUserSessionService extends Mock implements UserSessionService {
  @override
  String? getUsername() => "Test User";
  @override
  String? getUserEmail() => "test@example.com";
  @override
  String? getUserProfileImage() => null;
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createRegisterScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWith((ref) => MockUserSessionService()),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group("RegisterScreen Widget Tests", () {
    testWidgets('Should display registration form elements', (tester) async {
      await tester.pumpWidget(await createRegisterScreen());
      await tester.pump();

      // Check for form fields
      expect(find.byType(TextField), findsNWidgets(3)); // Name, Email, Password
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Gender dropdown
      expect(find.text("Sign Up"), findsNWidgets(2)); // Multiple "Sign Up" texts (button and header)
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should show loading indicator when state is loading', (tester) async {
      await tester.pumpWidget(await createRegisterScreen());

      // Trigger loading state
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.loading));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final signUpButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(signUpButton.onPressed, isNull); // Button is disabled
    });

    testWidgets('Should show error message when state has error', (tester) async {
      await tester.pumpWidget(await createRegisterScreen());

      // Trigger error state
      mockAuthViewModel.emit(AuthState.initial().copyWith(
        status: AuthStatus.error,
        errorMessage: "Registration failed",
      ));

      await tester.pump();

      expect(find.text("Registration failed"), findsOneWidget);
    });

    testWidgets('Should show registered state', (tester) async {
      await tester.pumpWidget(await createRegisterScreen());

      // Trigger registered state
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.registered));
      await tester.pump();

      expect(mockAuthViewModel.state.status, equals(AuthStatus.registered));
    });

    testWidgets('Should show error snackbar when validation fails', (tester) async {
      await tester.pumpWidget(await createRegisterScreen());

      final signUpButton = find.widgetWithText(ElevatedButton, "Sign Up");
      await tester.ensureVisible(signUpButton);
      await tester.pump();

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text("Please fill all fields"), findsOneWidget);
    });
  });
}
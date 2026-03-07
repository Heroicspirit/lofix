import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
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

  Future<Widget> createLoginScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWith((ref) => MockUserSessionService()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group("LoginScreen Widget Tests", () {
    testWidgets('Should display login form elements', (tester) async {
      await tester.pumpWidget(await createLoginScreen());
      await tester.pump();

      // Check for email and password fields
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text("Sign In"), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should show loading indicator when state is loading', (tester) async {
      await tester.pumpWidget(await createLoginScreen());

      // Manually trigger the loading state
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.loading));
      await tester.pump(); // Rebuild with new state

      // Check for the indicator and that the button is disabled
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('Should show error message when state has error', (tester) async {
      await tester.pumpWidget(await createLoginScreen());

      // Directly push an error state to test the listener
      mockAuthViewModel.emit(AuthState.initial().copyWith(
        status: AuthStatus.error,
        errorMessage: "Invalid email or password",
      ));

      await tester.pump(); // Trigger the listener logic

      expect(find.text("Invalid email or password"), findsOneWidget);
    });

    testWidgets('Should show error snackbar for empty fields', (tester) async {
      await tester.pumpWidget(await createLoginScreen());

      // Tap sign in button without filling fields
      await tester.tap(find.text("Sign In"));
      await tester.pump(); // Process the tap

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });
  });
}
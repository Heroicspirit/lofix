import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';


class MockAuthViewModel extends AuthViewModel with Mock {
  @override
  AuthState build() => AuthState.initial();


  @override
  Future<void> login({required String email, required String password}) async {}

  void emit(AuthState newState) {
    state = newState;
  }
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
  });


  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [

        authViewModelProvider.overrideWith(() => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group("LoginScreen Widget Tests", () {
    testWidgets('Should display error snackbar if fields are empty', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Ensure the button is there and tap it
      final signInButton = find.widgetWithText(ElevatedButton, "Sign In");
      await tester.tap(signInButton);
      
      // Pump once to trigger the ScaffoldMessenger/SnackBar
      await tester.pump(); 

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('Should show loading indicator when state is loading', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Manually trigger the loading state
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.loading));
      await tester.pump(); // Rebuild with new state

      // Check for the indicator and that the button is disabled
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('Successful login navigates to Dashboard', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Fill in the text fields
      await tester.enterText(find.byType(TextField).at(0), "test@user.com");
      await tester.enterText(find.byType(TextField).at(1), "password123");

      // Stub the login call so it doesn't crash or do anything
      when(() => mockAuthViewModel.login(
            email: "test@user.com",
            password: "password123",
          )).thenAnswer((_) async {});

      await tester.tap(find.text("Sign In"));
      
      // Simulate the ViewModel successfully authenticating
      mockAuthViewModel.emit(AuthState.initial().copyWith(status: AuthStatus.authenticated));
      
      // pumpAndSettle waits for the SnackBar and Navigation animations to finish
      await tester.pumpAndSettle(); 

      expect(find.text('Login successful!'), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('Failed login shows error message from state', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Directly push an error state to test the listener (ref.listen)
      mockAuthViewModel.emit(AuthState.initial().copyWith(
        status: AuthStatus.error,
        errorMessage: "Unauthorized: Invalid email or password",
      ));

      await tester.pump(); // Trigger the listener logic

      expect(find.text("Unauthorized: Invalid email or password"), findsOneWidget);
    });
  });
}
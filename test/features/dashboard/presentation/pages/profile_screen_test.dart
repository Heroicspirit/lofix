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


class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel();

  bool logoutCalled = false;

  @override
  AuthState build() => AuthState.initial();

  @override
  Future<void> register({required String email, required String name, required String password}) async {
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

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late TestAuthViewModel mockAuthViewModel;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockAuthViewModel = TestAuthViewModel();
    mockSharedPreferences = MockSharedPreferences();
    
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
  });

  Widget createProfileScreen() {
    return ProviderScope(
      overrides: [

        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen UI Tests', () {
    testWidgets('Tapping logout icon calls authViewModel.logout()', (WidgetTester tester) async {
      await tester.pumpWidget(createProfileScreen());


      final logoutFinder = find.byIcon(Icons.logout);
      expect(logoutFinder, findsOneWidget);


      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();


      expect(mockAuthViewModel.logoutCalled, isTrue);
    });
  });
}
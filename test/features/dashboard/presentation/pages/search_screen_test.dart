import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/features/dashboard/presentation/pages/search_screen.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';
import 'package:musicapp/app/theme/theme_provider.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

class MockUserSessionService extends Mock implements UserSessionService {
  @override
  String? getUsername() => "Test User";
  @override
  String? getUserEmail() => "test@example.com";
  @override
  String? getUserProfileImage() => null;
}

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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createSearchScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWith((ref) => MockUserSessionService()),
        offlineModeProvider.overrideWith((ref) => MockOfflineModeNotifier()),
      ],
      child: const MaterialApp(
        home: SearchScreen(),
      ),
    );
  }

  group('SearchScreen Widget Tests', () {
    testWidgets('SearchScreen displays search input field', (WidgetTester tester) async {
      await tester.pumpWidget(await createSearchScreen());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SearchScreen has proper app bar', (WidgetTester tester) async {
      await tester.pumpWidget(await createSearchScreen());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('SearchScreen can handle text input', (WidgetTester tester) async {
      await tester.pumpWidget(await createSearchScreen());
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'test query');
      await tester.pump();

      expect(find.text('test query'), findsOneWidget);
    });

    testWidgets('SearchScreen has proper scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(await createSearchScreen());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Search input field is interactive', (WidgetTester tester) async {
      await tester.pumpWidget(await createSearchScreen());
      await tester.pump();

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pump();

      expect(searchField, findsOneWidget);
    });
  });
}
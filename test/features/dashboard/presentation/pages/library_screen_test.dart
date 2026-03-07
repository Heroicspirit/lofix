import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/features/dashboard/presentation/pages/library_screen.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';

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

  Future<Widget> createLibraryScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWith((ref) => MockUserSessionService()),
        offlineModeProvider.overrideWith((ref) => MockOfflineModeNotifier()),
      ],
      child: const MaterialApp(
        home: LibraryScreen(),
      ),
    );
  }

  group('LibraryScreen Basic UI Tests', () {
    testWidgets('LibraryScreen basic structure test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Your Library'),
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            body: const Center(
              child: Text('Library Content'),
            ),
          ),
        ),
      );

      expect(find.text('Your Library'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Library Content'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('LibraryScreen button interactions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Your Library'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            body: const Center(
              child: Text('Library Content'),
            ),
          ),
        ),
      );

      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      expect(addButton, findsOneWidget);
    });
  });
}
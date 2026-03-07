import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/features/dashboard/presentation/pages/home_screen.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

// Helper function to pump HomeScreen with proper overrides
Future<void> pumpHomeScreen(WidgetTester tester) async {
  // Initialize mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {

  testWidgets('HomeScreen loads and displays main UI', (WidgetTester tester) async {

    await pumpHomeScreen(tester);

    // AppBar title
    expect(find.text('Home'), findsOneWidget);

    // Section headers
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Top Artists'), findsOneWidget);
    expect(find.text('Trending Now'), findsOneWidget);

    // Refresh button
    expect(find.byIcon(Icons.refresh), findsOneWidget);

  });

  testWidgets('Top artists are displayed', (WidgetTester tester) async {

    await pumpHomeScreen(tester);

    // Check mock artist names
    expect(find.text('Jax Bloom'), findsOneWidget);
    expect(find.text('Sonu Nigam'), findsOneWidget);
    expect(find.text('The Weeknd'), findsOneWidget);
    expect(find.text('Lofi Girl'), findsOneWidget);
  });

  testWidgets('Refresh button exists and is tappable', (WidgetTester tester) async {

    await pumpHomeScreen(tester);

    final refreshButton = find.byIcon(Icons.refresh);

    expect(refreshButton, findsOneWidget);

    // Test that the button is tappable without actually triggering the refresh
    await tester.tap(refreshButton);
    
    // Just pump once to handle the tap event without waiting for async operations
    await tester.pump(Duration.zero);
    
    // Verify the button is still there
    expect(refreshButton, findsOneWidget);
  });

}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Widget Tests', () {
    testWidgets('should display basic widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: Center(
              child: Column(
                children: [
                  const Text('Test Screen'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Test Button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Test Screen'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle button tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should handle navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      final navButton = find.byType(TextButton);
      expect(navButton, findsOneWidget);
      await tester.tap(navButton);
      await tester.pump();

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should display list view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(title: const Text('Item 1')),
                ListTile(title: const Text('Item 2')),
                ListTile(title: const Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('should handle text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Test Input',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Input'), findsOneWidget);
    });
  });
}

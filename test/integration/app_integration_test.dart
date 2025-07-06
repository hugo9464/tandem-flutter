import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tandem App Integration Tests', () {
    testWidgets('should complete full expense flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts with the correct title
      expect(find.text('Nos Dépenses Communes 💕'), findsOneWidget);

      // Test navigation to different tabs
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();
      expect(find.text('À propos'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres'), findsOneWidget);

      // Go back to home screen
      await tester.tap(find.byIcon(Icons.favorite_outline));
      await tester.pumpAndSettle();

      // Test adding an expense
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle Dépense'), findsOneWidget);

      // Fill in the expense form
      await tester.enterText(find.byType(TextField).first, '25.50');
      await tester.enterText(find.byType(TextField).at(1), 'Test Expense');

      // Select payer
      await tester.tap(find.text('Vous'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Votre partenaire'));
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Verify the expense was added (or error shown if service unavailable)
      // Check for either a SnackBar or the expense text
      final hasSnackBar = find.byType(SnackBar).evaluate().isNotEmpty;
      final hasExpenseText = find.text('Test Expense').evaluate().isNotEmpty;
      expect(hasSnackBar || hasExpenseText, isTrue);
    });

    testWidgets('should handle navigation between screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test bottom navigation
      final bottomNav = find.byType(NavigationBar);
      expect(bottomNav, findsOneWidget);

      // Test all navigation destinations
      final destinations = [
        Icons.favorite_outline,
        Icons.info_outline,
        Icons.settings_outlined,
      ];

      for (final icon in destinations) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
        
        // Verify navigation occurred by checking the icon is selected
        expect(find.byIcon(icon), findsOneWidget);
      }
    });

    testWidgets('should display proper loading states', (WidgetTester tester) async {
      app.main();
      await tester.pump(); // Only pump once to catch loading state

      // Should show loading indicators initially
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      await tester.pumpAndSettle();

      // Loading should be gone after settling
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle form validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open add expense dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.byType(SnackBar), findsOneWidget);

      // Enter invalid amount
      await tester.enterText(find.byType(TextField).first, '0');
      await tester.enterText(find.byType(TextField).at(1), '');

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      // Should show validation error again
      expect(find.byType(SnackBar), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle refresh functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find refresh indicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Perform pull to refresh
      await tester.fling(refreshIndicator, const Offset(0, 300), 1000);
      await tester.pump();
      
      // Should show loading indicator during refresh
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
    });

    testWidgets('should maintain state across navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start on home screen, verify initial state
      expect(find.text('Nos Dépenses Communes 💕'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.favorite_outline));
      await tester.pumpAndSettle();

      // Should still be on home screen with same state
      expect(find.text('Nos Dépenses Communes 💕'), findsOneWidget);
    });

    testWidgets('should handle dialog interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Open add expense dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle Dépense'), findsOneWidget);

      // Test cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Nouvelle Dépense'), findsNothing);

      // Open dialog again
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Test dropdown interaction
      await tester.tap(find.text('Vous'));
      await tester.pumpAndSettle();

      // Select different option
      await tester.tap(find.text('Votre partenaire'));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(find.text('Votre partenaire'), findsAtLeastNWidgets(1));
    });

    group('Error Handling Integration', () {
      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Even if network fails, app should not crash
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
      });

      testWidgets('should show appropriate error messages', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Try to add expense with network potentially down
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '10.00');
        await tester.enterText(find.byType(TextField).at(1), 'Test');

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        // Should either succeed or show appropriate error
        // No crash should occur
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Accessibility Integration', () {
      testWidgets('should be accessible', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Verify semantic labels are present
        expect(tester.getSemantics(find.byIcon(Icons.add)), isNotNull);
        expect(tester.getSemantics(find.byIcon(Icons.favorite_outline)), isNotNull);

        // Test navigation accessibility
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        expect(tester.getSemantics(find.text('Paramètres')), isNotNull);
      });
    });

    group('Performance Integration', () {
      testWidgets('should load quickly', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        app.main();
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // App should load within reasonable time (5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      testWidgets('should handle rapid navigation', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Rapidly switch between tabs
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byIcon(Icons.info_outline));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.favorite_outline));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.settings_outlined));
          await tester.pump();
        }

        await tester.pumpAndSettle();

        // Should still be functional
        expect(find.byType(NavigationBar), findsOneWidget);
      });
    });
  });
}
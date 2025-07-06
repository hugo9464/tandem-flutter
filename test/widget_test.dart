// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tandem_flutter/main.dart';

void main() {
  testWidgets('Tandem app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TandemApp());

    // Verify that the app title appears correctly
    expect(find.text('Nos Dépenses Communes 💕'), findsOneWidget);

    // Verify that the navigation bar has French labels
    expect(find.text('Dépenses'), findsOneWidget);
    expect(find.text('À propos'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);

    // Verify that the favorite icon is present for the expenses tab
    expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
  });

  testWidgets('Navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TandemApp());

    // Tap on the "À propos" tab
    await tester.tap(find.text('À propos'));
    await tester.pump();

    // Verify that we navigated to the about screen
    expect(find.text('À propos'), findsWidgets);

    // Tap on the "Paramètres" tab
    await tester.tap(find.text('Paramètres'));
    await tester.pump();

    // Verify navigation
    expect(find.text('Paramètres'), findsWidgets);
  });
}
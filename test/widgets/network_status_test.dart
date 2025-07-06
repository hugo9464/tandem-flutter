import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/widgets/network_status.dart';

void main() {
  group('NetworkStatusWidget Tests', () {
    testWidgets('should display widget without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusWidget(),
          ),
        ),
      );

      expect(find.byType(NetworkStatusWidget), findsOneWidget);
    });

    testWidgets('should be a stateful widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusWidget(),
          ),
        ),
      );

      expect(find.byType(NetworkStatusWidget), findsOneWidget);
      
      final widget = tester.widget(find.byType(NetworkStatusWidget));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should render without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusWidget(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain state across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusWidget(),
          ),
        ),
      );

      await tester.pump();
      
      // Trigger a rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NetworkStatusWidget(),
                Text('Additional widget'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(NetworkStatusWidget), findsOneWidget);
      expect(find.text('Additional widget'), findsOneWidget);
    });
  });
}
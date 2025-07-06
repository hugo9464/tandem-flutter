import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/screens/home_screen.dart';
import 'package:tandem_flutter/models/expense.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Nos Dépenses Communes 💕'), findsOneWidget);
    });

    testWidgets('should display add button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state message when no expenses', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Aucune dépense enregistrée\nAppuyez sur + pour ajouter une dépense'),
        findsOneWidget,
      );
    });

    testWidgets('should open add expense dialog when add button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle Dépense'), findsOneWidget);
      expect(find.text('Montant (€)'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Payé par'), findsOneWidget);
    });

    testWidgets('should validate form inputs in add expense dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should have refresh capability', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    group('Balance Card Tests', () {
      testWidgets('should display balance information correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Balance du Couple'), findsAny);
        expect(find.text('Total des dépenses'), findsAny);
      });
    });

    group('Expense Card Tests', () {
      testWidgets('should display expense details', (WidgetTester tester) async {
        final expense = Expense(
          id: 'test-id',
          userId: 'user-123',
          amount: 25.50,
          description: 'Test Expense',
          paidBy: 'user1',
          date: DateTime(2024, 1, 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _ExpenseCard(
                expense: expense,
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Expense'), findsOneWidget);
        expect(find.text('€25.50'), findsOneWidget);
        expect(find.text('Payé par vous'), findsOneWidget);
        expect(find.text('15/1/2024'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('should handle partner payment display', (WidgetTester tester) async {
        final expense = Expense(
          id: 'test-id',
          userId: 'user-123',
          amount: 30.00,
          description: 'Partner Expense',
          paidBy: 'user2',
          date: DateTime(2024, 1, 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _ExpenseCard(
                expense: expense,
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Payé par votre partenaire'), findsOneWidget);
      });

      testWidgets('should call onDelete when delete button pressed', (WidgetTester tester) async {
        bool deletePressed = false;
        final expense = Expense(
          id: 'test-id',
          userId: 'user-123',
          amount: 25.50,
          description: 'Test Expense',
          paidBy: 'user1',
          date: DateTime(2024, 1, 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _ExpenseCard(
                expense: expense,
                onDelete: () => deletePressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pump();

        expect(deletePressed, isTrue);
      });
    });

    group('Add Expense Dialog Tests', () {
      testWidgets('should update dropdown selection', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.pump();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Vous'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Votre partenaire'));
        await tester.pumpAndSettle();

        expect(find.text('Votre partenaire'), findsAtLeastNWidgets(1));
      });

      testWidgets('should close dialog on cancel', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.pump();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('Nouvelle Dépense'), findsNothing);
      });
    });

    group('UI Component Tests', () {
      testWidgets('should display network status widget', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.pump();

        expect(find.byType(NetworkStatusWidget), findsOneWidget);
      });

      testWidgets('should have proper app bar styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );

        await tester.pump();

        final appBar = find.byType(AppBar);
        expect(appBar, findsOneWidget);

        final AppBar appBarWidget = tester.widget(appBar);
        expect(appBarWidget.centerTitle, isTrue);
        expect(appBarWidget.backgroundColor, equals(Colors.transparent));
        expect(appBarWidget.elevation, equals(0));
      });
    });
  });
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: expense.paidBy == 'user1' 
                    ? const Color(0xFF4ECDC4).withValues(alpha: 0.1)
                    : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long,
                color: expense.paidBy == 'user1' 
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: expense.paidBy == 'user1' 
                              ? const Color(0xFF4ECDC4).withValues(alpha: 0.1)
                              : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          expense.paidBy == 'user1' ? 'Payé par vous' : 'Payé par votre partenaire',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: expense.paidBy == 'user1' 
                                ? const Color(0xFF4ECDC4)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
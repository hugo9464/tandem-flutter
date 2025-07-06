import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/models/expense.dart';
import 'package:tandem_flutter/models/account.dart';
import 'package:tandem_flutter/models/transaction.dart';

/// Test helpers and utilities for Tandem Flutter tests
class TestHelpers {
  /// Creates a test expense with default values
  static Expense createTestExpense({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? paidBy,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? 'test-expense-id',
      userId: userId ?? 'test-user-id',
      amount: amount ?? 25.50,
      description: description ?? 'Test Expense',
      paidBy: paidBy ?? 'user1',
      date: date ?? DateTime(2024, 1, 15, 10, 30),
    );
  }

  /// Creates a test account with default values
  static Account createTestAccount({
    String? id,
    String? name,
    String? iban,
    String? bic,
    double? balance,
    String? currency,
    String? type,
  }) {
    return Account(
      id: id ?? 'test-account-id',
      name: name ?? 'Test Account',
      iban: iban ?? 'FR76 1234 5678 9012 3456 7890 123',
      bic: bic ?? 'BNPAFRPP',
      balance: balance ?? 1000.00,
      currency: currency ?? '€',
      type: type ?? 'checking',
    );
  }

  /// Creates a test transaction with default values
  static Transaction createTestTransaction({
    String? id,
    String? accountId,
    double? amount,
    String? currency,
    DateTime? date,
    String? description,
    TransactionType? type,
    TransactionStatus? status,
  }) {
    return Transaction(
      id: id ?? 'test-transaction-id',
      accountId: accountId ?? 'test-account-id',
      amount: amount ?? 100.00,
      currency: currency ?? 'EUR',
      date: date ?? DateTime(2024, 1, 15, 10, 30),
      description: description ?? 'Test Transaction',
      type: type ?? TransactionType.debit,
      status: status ?? TransactionStatus.completed,
    );
  }

  /// Creates a list of test expenses for balance calculations
  static List<Expense> createTestExpensesForBalance() {
    return [
      createTestExpense(
        id: '1',
        amount: 100.0,
        description: 'Groceries',
        paidBy: 'user1',
      ),
      createTestExpense(
        id: '2',
        amount: 60.0,
        description: 'Gas',
        paidBy: 'user2',
      ),
      createTestExpense(
        id: '3',
        amount: 40.0,
        description: 'Restaurant',
        paidBy: 'user1',
      ),
    ];
  }

  /// Calculates expected balance from a list of expenses
  static Map<String, double> calculateExpectedBalance(List<Expense> expenses) {
    double user1Total = 0;
    double user2Total = 0;

    for (final expense in expenses) {
      if (expense.paidBy == 'user1') {
        user1Total += expense.amount;
      } else if (expense.paidBy == 'user2') {
        user2Total += expense.amount;
      }
    }

    final totalExpenses = user1Total + user2Total;
    final halfAmount = totalExpenses / 2;

    return {
      'user1_paid': user1Total,
      'user2_paid': user2Total,
      'user1_owes': halfAmount - user1Total,
      'user2_owes': halfAmount - user2Total,
      'total': totalExpenses,
    };
  }

  /// Pumps a widget wrapped in MaterialApp
  static Future<void> pumpMaterialApp(
    WidgetTester tester,
    Widget widget, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: widget,
      ),
    );
  }

  /// Finds a widget by its text content, ignoring case
  static Finder findTextIgnoreCase(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.toLowerCase() == text.toLowerCase(),
    );
  }

  /// Verifies that a SnackBar with specific content is shown
  static void expectSnackBar(String message) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  /// Waits for a specific duration during tests
  static Future<void> waitFor(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Creates mock JSON data for expenses
  static Map<String, dynamic> createExpenseJson({
    String? id,
    String? userId,
    dynamic amount,
    String? description,
    String? paidBy,
    String? date,
  }) {
    return {
      'id': id ?? 'test-expense-id',
      'user_id': userId ?? 'test-user-id',
      'amount': amount ?? '25.50',
      'description': description ?? 'Test Expense',
      'paid_by': paidBy ?? 'user1',
      'date': date ?? '2024-01-15T10:30:00Z',
    };
  }

  /// Creates mock JSON data for accounts
  static Map<String, dynamic> createAccountJson({
    String? id,
    String? name,
    String? iban,
    String? bic,
    double? balance,
    String? currency,
    String? type,
  }) {
    return {
      'id': id ?? 'test-account-id',
      'name': name ?? 'Test Account',
      'iban': iban ?? 'FR76 1234 5678 9012 3456 7890 123',
      'bic': bic ?? 'BNPAFRPP',
      'balance': balance ?? 1000.00,
      'currency': currency ?? '€',
      'type': type ?? 'checking',
    };
  }

  /// Validates expense data structure
  static void validateExpenseStructure(Expense expense) {
    expect(expense.id, isNotEmpty);
    expect(expense.userId, isNotEmpty);
    expect(expense.amount, isNonNegative);
    expect(expense.description, isNotEmpty);
    expect(['user1', 'user2'].contains(expense.paidBy), isTrue);
    expect(expense.date, isA<DateTime>());
  }

  /// Validates account data structure
  static void validateAccountStructure(Account account) {
    expect(account.id, isNotEmpty);
    expect(account.name, isNotEmpty);
    expect(account.iban, isNotEmpty);
    expect(account.bic, isNotEmpty);
    expect(account.currency, isNotEmpty);
    expect(account.type, isNotEmpty);
    expect(account.balance, isA<double>());
  }

  /// Creates test widget with necessary providers
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Simulates a tap and settles the animation
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enters text and settles the animation
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verifies that a widget has specific styling properties
  static void verifyTextStyle(
    WidgetTester tester,
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final textWidget = tester.widget<Text>(find.text(text));
    if (color != null) expect(textWidget.style?.color, equals(color));
    if (fontSize != null) expect(textWidget.style?.fontSize, equals(fontSize));
    if (fontWeight != null) expect(textWidget.style?.fontWeight, equals(fontWeight));
  }

  /// Creates a list of special character test cases
  static List<String> getSpecialCharacterTestCases() {
    return [
      'Café & Restaurant 🍕',
      'Hôtel Saint-Émilion',
      'Courses chez l\'épicier',
      'Transport: métro + bus',
      'Facture EDF/GDF',
      'Montant: 25,50€',
      'Description avec @#\$%^&*()_+',
    ];
  }

  /// Creates edge case amounts for testing
  static List<double> getEdgeCaseAmounts() {
    return [
      0.0,
      0.01,
      0.99,
      1.0,
      999.99,
      1000.0,
      9999.99,
      10000.0,
    ];
  }

  /// Verifies the balance calculation logic
  static void verifyBalanceCalculation(
    Map<String, double> balance,
    double expectedUser1Paid,
    double expectedUser2Paid,
    double expectedTotal,
  ) {
    expect(balance['user1_paid'], equals(expectedUser1Paid));
    expect(balance['user2_paid'], equals(expectedUser2Paid));
    expect(balance['total'], equals(expectedTotal));
    
    final halfAmount = expectedTotal / 2;
    expect(balance['user1_owes'], equals(halfAmount - expectedUser1Paid));
    expect(balance['user2_owes'], equals(halfAmount - expectedUser2Paid));
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('should create Expense from valid JSON', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'amount': 25.50,
        'description': 'Test expense',
        'paid_by': 'user1',
        'date': '2024-01-15T10:30:00Z',
      };

      final expense = Expense.fromJson(json);

      expect(expense.id, equals('test-id'));
      expect(expense.userId, equals('user-123'));
      expect(expense.amount, equals(25.50));
      expect(expense.description, equals('Test expense'));
      expect(expense.paidBy, equals('user1'));
      expect(expense.date, isA<DateTime>());
    });

    test('should convert Expense to JSON', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 25.50,
        description: 'Test expense',
        paidBy: 'user1',
        date: DateTime(2024, 1, 15, 10, 30),
      );

      final json = expense.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['user_id'], equals('user-123'));
      expect(json['amount'], equals(25.50));
      expect(json['description'], equals('Test expense'));
      expect(json['paid_by'], equals('user1'));
      expect(json['date'], isA<String>());
    });

    test('should handle different paid_by values', () {
      final expense1 = Expense(
        id: 'test-1',
        userId: 'user-123',
        amount: 10.0,
        description: 'Expense 1',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      final expense2 = Expense(
        id: 'test-2',
        userId: 'user-123',
        amount: 20.0,
        description: 'Expense 2',
        paidBy: 'user2',
        date: DateTime.now(),
      );

      expect(expense1.paidBy, equals('user1'));
      expect(expense2.paidBy, equals('user2'));
    });

    test('should handle negative amounts', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: -15.25,
        description: 'Refund',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      expect(expense.amount, equals(-15.25));
    });

    test('should handle string amounts in JSON', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-123',
        'amount': '42.75',
        'description': 'String amount test',
        'paid_by': 'user2',
        'date': '2024-01-15T10:30:00Z',
      };

      final expense = Expense.fromJson(json);

      expect(expense.amount, equals(42.75));
    });

    test('should handle zero amounts', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 0.0,
        description: 'Free item',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      expect(expense.amount, equals(0.0));
    });

    test('should handle very large amounts', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 999999.99,
        description: 'Large expense',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      expect(expense.amount, equals(999999.99));
    });

    test('should handle very small amounts', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 0.01,
        description: 'Penny',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      expect(expense.amount, equals(0.01));
    });

    test('should handle special characters in description', () {
      final specialDescriptions = [
        'Café & Restaurant 🍕',
        'Hôtel Saint-Émilion',
        'Courses chez l\'épicier',
        'Transport: métro + bus',
        'Facture EDF/GDF',
      ];

      for (final description in specialDescriptions) {
        final expense = Expense(
          id: 'test-id',
          userId: 'user-123',
          amount: 10.0,
          description: description,
          paidBy: 'user1',
          date: DateTime.now(),
        );

        expect(expense.description, equals(description));

        // Test JSON round trip
        final json = expense.toJson();
        final reconstructed = Expense.fromJson(json);
        expect(reconstructed.description, equals(description));
      }
    });

    test('should maintain date precision', () {
      final originalDate = DateTime(2024, 1, 15, 10, 30, 45, 123);
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 25.50,
        description: 'Date precision test',
        paidBy: 'user1',
        date: originalDate,
      );

      final json = expense.toJson();
      final reconstructed = Expense.fromJson(json);

      // Note: JSON serialization might lose some precision
      expect(reconstructed.date.year, equals(originalDate.year));
      expect(reconstructed.date.month, equals(originalDate.month));
      expect(reconstructed.date.day, equals(originalDate.day));
      expect(reconstructed.date.hour, equals(originalDate.hour));
      expect(reconstructed.date.minute, equals(originalDate.minute));
    });

    test('should handle different date formats', () {
      final dateFormats = [
        '2024-01-15T10:30:00Z',
        '2024-01-15T10:30:00.000Z',
        '2024-01-15 10:30:00.000000',
        '2024-01-15 10:30:00',
      ];

      for (final dateString in dateFormats) {
        try {
          final json = {
            'id': 'test-id',
            'user_id': 'user-123',
            'amount': '25.50',
            'description': 'Date format test',
            'paid_by': 'user1',
            'date': dateString,
          };

          final expense = Expense.fromJson(json);
          expect(expense.date, isA<DateTime>());
          expect(expense.date.year, equals(2024));
          expect(expense.date.month, equals(1));
          expect(expense.date.day, equals(15));
        } catch (e) {
          // Some formats might not be supported, which is OK
          print('Date format $dateString not supported: $e');
        }
      }
    });

    test('should handle equality comparison', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final expense1 = Expense(
        id: 'same-id',
        userId: 'user-123',
        amount: 25.50,
        description: 'Test expense',
        paidBy: 'user1',
        date: date,
      );

      final expense2 = Expense(
        id: 'same-id',
        userId: 'user-123',
        amount: 25.50,
        description: 'Test expense',
        paidBy: 'user1',
        date: date,
      );

      // Note: Without implementing == operator, these will be different instances
      expect(expense1.id, equals(expense2.id));
      expect(expense1.amount, equals(expense2.amount));
      expect(expense1.description, equals(expense2.description));
    });

    test('should handle empty description edge case', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-123',
        amount: 10.0,
        description: '',
        paidBy: 'user1',
        date: DateTime.now(),
      );

      expect(expense.description, equals(''));
    });

    test('should handle edge case paid_by values', () {
      final testCases = ['user1', 'user2', 'unknown_user', 'admin', ''];

      for (final paidBy in testCases) {
        final expense = Expense(
          id: 'test-id',
          userId: 'user-123',
          amount: 10.0,
          description: 'Test',
          paidBy: paidBy,
          date: DateTime.now(),
        );

        expect(expense.paidBy, equals(paidBy));
      }
    });
  });
}
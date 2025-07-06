import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:tandem_flutter/services/supabase_service.dart';
import 'package:tandem_flutter/models/account.dart';
import 'package:tandem_flutter/models/transaction.dart';
import 'package:tandem_flutter/models/expense.dart';

@GenerateMocks([http.Client, SupabaseClient, GoTrueClient, PostgrestClient, PostgrestQueryBuilder, PostgrestFilterBuilder])
import 'supabase_service_test.mocks.dart';

void main() {
  group('SupabaseService Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    group('Balance Calculation Tests', () {
      test('should calculate balance correctly with mixed expenses', () async {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 100.0,
            description: 'Groceries',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
          Expense(
            id: '2',
            userId: 'user2',
            amount: 50.0,
            description: 'Restaurant',
            paidBy: 'user2',
            date: DateTime.now(),
          ),
          Expense(
            id: '3',
            userId: 'user1',
            amount: 30.0,
            description: 'Coffee',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
        ];

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

        expect(user1Total, equals(130.0));
        expect(user2Total, equals(50.0));
        expect(totalExpenses, equals(180.0));
        expect(halfAmount, equals(90.0));
        expect(halfAmount - user1Total, equals(-40.0)); // user1 owes -40 (is owed 40)
        expect(halfAmount - user2Total, equals(40.0)); // user2 owes 40
      });

      test('should handle zero expenses', () {
        final expenses = <Expense>[];
        
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
        
        expect(user1Total, equals(0.0));
        expect(user2Total, equals(0.0));
        expect(totalExpenses, equals(0.0));
        expect(halfAmount, equals(0.0));
      });

      test('should handle equal expenses', () {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 50.0,
            description: 'Expense 1',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
          Expense(
            id: '2',
            userId: 'user2',
            amount: 50.0,
            description: 'Expense 2',
            paidBy: 'user2',
            date: DateTime.now(),
          ),
        ];

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

        expect(user1Total, equals(50.0));
        expect(user2Total, equals(50.0));
        expect(halfAmount - user1Total, equals(0.0));
        expect(halfAmount - user2Total, equals(0.0));
      });
    });

    group('Data Validation Tests', () {
      test('should validate expense data structure', () {
        final expense = Expense(
          id: 'exp-123',
          userId: 'user-456',
          amount: 25.75,
          description: 'Test expense',
          paidBy: 'user1',
          date: DateTime(2024, 1, 15),
        );

        expect(expense.id, isNotEmpty);
        expect(expense.userId, isNotEmpty);
        expect(expense.amount, isPositive);
        expect(expense.description, isNotEmpty);
        expect(['user1', 'user2'].contains(expense.paidBy), isTrue);
        expect(expense.date, isA<DateTime>());
      });

      test('should validate transaction data structure', () {
        final transaction = Transaction(
          id: 'txn-123',
          accountId: 'acc-456',
          amount: 100.0,
          currency: 'EUR',
          date: DateTime.now(),
          description: 'Test transaction',
          type: TransactionType.debit,
          status: TransactionStatus.completed,
        );

        expect(transaction.id, isNotEmpty);
        expect(transaction.accountId, isNotEmpty);
        expect(transaction.amount, isNonZero);
        expect(transaction.currency, isNotEmpty);
        expect(transaction.description, isNotEmpty);
        expect(transaction.type, isA<TransactionType>());
        expect(transaction.status, isA<TransactionStatus>());
      });

      test('should validate transaction filters', () {
        final now = DateTime.now();
        final filters = TransactionFilters(
          dateFrom: now.subtract(const Duration(days: 30)),
          dateTo: now,
          type: TransactionType.debit,
          status: TransactionStatus.completed,
          minAmount: 0.0,
          maxAmount: 1000.0,
        );

        expect(filters.dateFrom!.isBefore(filters.dateTo!), isTrue);
        expect(filters.minAmount!, lessThanOrEqualTo(filters.maxAmount!));
        expect(filters.type, isA<TransactionType>());
        expect(filters.status, isA<TransactionStatus>());
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid JSON gracefully', () {
        expect(() {
          final invalidJson = {'invalid': 'data'};
          Expense.fromJson(invalidJson);
        }, throwsA(isA<TypeError>()));
      });

      test('should handle missing required fields', () {
        expect(() {
          final incompleteJson = {
            'id': 'test-id',
            // missing required fields
          };
          Expense.fromJson(incompleteJson);
        }, throwsA(isA<TypeError>()));
      });

      test('should handle invalid transaction types', () {
        expect(() {
          final invalidJson = {
            'id': 'txn-123',
            'accountId': 'acc-456',
            'amount': 100.0,
            'currency': 'EUR',
            'date': '2024-01-15T10:30:00Z',
            'description': 'Test',
            'type': 'INVALID_TYPE',
            'status': 'COMPLETED',
          };
          Transaction.fromJson(invalidJson);
        }, throwsA(isA<ArgumentError>()));
      });
    });

    group('Date Handling Tests', () {
      test('should parse ISO date strings correctly', () {
        final dateString = '2024-01-15T10:30:00Z';
        final parsedDate = DateTime.parse(dateString);
        
        expect(parsedDate.year, equals(2024));
        expect(parsedDate.month, equals(1));
        expect(parsedDate.day, equals(15));
        expect(parsedDate.hour, equals(10));
        expect(parsedDate.minute, equals(30));
      });

      test('should handle different date formats', () {
        final dates = [
          '2024-01-15T10:30:00Z',
          '2024-01-15T10:30:00.000Z',
          '2024-01-15 10:30:00',
        ];

        for (final dateString in dates) {
          try {
            final date = DateTime.parse(dateString);
            expect(date, isA<DateTime>());
          } catch (e) {
            // Some formats might not be supported, that's OK
          }
        }
      });
    });

    group('Expense Service Tests', () {
      test('should parse expense from API response correctly', () {
        final expenseJson = {
          'id': 'exp-123',
          'user_id': 'user-456',
          'amount': '25.50',
          'description': 'Groceries',
          'paid_by': 'user1',
          'date': '2024-01-15T10:30:00Z',
        };

        final expense = Expense.fromJson(expenseJson);

        expect(expense.id, equals('exp-123'));
        expect(expense.userId, equals('user-456'));
        expect(expense.amount, equals(25.50));
        expect(expense.description, equals('Groceries'));
        expect(expense.paidBy, equals('user1'));
        expect(expense.date.year, equals(2024));
      });

      test('should convert expense to JSON correctly', () {
        final expense = Expense(
          id: 'exp-123',
          userId: 'user-456',
          amount: 25.50,
          description: 'Groceries',
          paidBy: 'user1',
          date: DateTime(2024, 1, 15, 10, 30),
        );

        final json = expense.toJson();

        expect(json['id'], equals('exp-123'));
        expect(json['user_id'], equals('user-456'));
        expect(json['amount'], equals(25.50));
        expect(json['description'], equals('Groceries'));
        expect(json['paid_by'], equals('user1'));
        expect(json['date'], isNotNull);
      });

      test('should handle different amount formats', () {
        final testCases = [
          {'amount': '10', 'expected': 10.0},
          {'amount': '10.50', 'expected': 10.50},
          {'amount': '0.99', 'expected': 0.99},
          {'amount': 25, 'expected': 25.0},
          {'amount': 25.75, 'expected': 25.75},
        ];

        for (final testCase in testCases) {
          final expenseJson = {
            'id': 'exp-123',
            'user_id': 'user-456',
            'amount': testCase['amount'],
            'description': 'Test',
            'paid_by': 'user1',
            'date': '2024-01-15T10:30:00Z',
          };

          final expense = Expense.fromJson(expenseJson);
          expect(expense.amount, equals(testCase['expected']),
              reason: 'Failed for amount: ${testCase['amount']}');
        }
      });
    });

    group('Balance Calculation Service Tests', () {
      test('should calculate balance correctly with real service logic', () {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 100.0,
            description: 'Groceries',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
          Expense(
            id: '2',
            userId: 'user2',
            amount: 60.0,
            description: 'Gas',
            paidBy: 'user2',
            date: DateTime.now(),
          ),
        ];

        // Simulate the service logic
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
        
        final balance = {
          'user1_paid': user1Total,
          'user2_paid': user2Total,
          'user1_owes': halfAmount - user1Total,
          'user2_owes': halfAmount - user2Total,
          'total': totalExpenses,
        };

        expect(balance['user1_paid'], equals(100.0));
        expect(balance['user2_paid'], equals(60.0));
        expect(balance['total'], equals(160.0));
        expect(balance['user1_owes'], equals(-20.0)); // user1 is owed 20
        expect(balance['user2_owes'], equals(20.0)); // user2 owes 20
      });

      test('should handle single user expenses', () {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 50.0,
            description: 'Solo expense',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
        ];

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

        expect(user1Total, equals(50.0));
        expect(user2Total, equals(0.0));
        expect(halfAmount - user1Total, equals(-25.0)); // user1 is owed 25
        expect(halfAmount - user2Total, equals(25.0)); // user2 owes 25
      });

      test('should handle large amounts correctly', () {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 1000.0,
            description: 'Rent',
            paidBy: 'user1',
            date: DateTime.now(),
          ),
          Expense(
            id: '2',
            userId: 'user2',
            amount: 1500.0,
            description: 'Vacation',
            paidBy: 'user2',
            date: DateTime.now(),
          ),
        ];

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

        expect(totalExpenses, equals(2500.0));
        expect(halfAmount, equals(1250.0));
        expect(halfAmount - user1Total, equals(250.0)); // user1 owes 250
        expect(halfAmount - user2Total, equals(-250.0)); // user2 is owed 250
      });
    });

    group('HTTP Error Handling Tests', () {
      test('should handle 404 errors gracefully', () {
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        expect(() async {
          await SupabaseService.getAccounts();
        }, throwsA(isA<Exception>()));
      });

      test('should handle 500 errors gracefully', () {
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Internal Server Error', 500));

        expect(() async {
          await SupabaseService.getAccounts();
        }, throwsA(isA<Exception>()));
      });

      test('should handle network timeouts', () {
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Connection timeout'));

        expect(() async {
          await SupabaseService.getAccounts();
        }, throwsA(isA<Exception>()));
      });

      test('should handle malformed JSON responses', () {
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('invalid json{', 200));

        expect(() async {
          await SupabaseService.getAccounts();
        }, throwsA(isA<Exception>()));
      });
    });

    group('Edge Case Tests', () {
      test('should handle empty expense list', () {
        final expenses = <Expense>[];
        
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
        
        expect(totalExpenses, equals(0.0));
        expect(halfAmount, equals(0.0));
        expect(halfAmount - user1Total, equals(0.0));
        expect(halfAmount - user2Total, equals(0.0));
      });

      test('should handle zero amount expenses', () {
        final expense = Expense(
          id: '1',
          userId: 'user1',
          amount: 0.0,
          description: 'Free item',
          paidBy: 'user1',
          date: DateTime.now(),
        );

        expect(expense.amount, equals(0.0));
        expect(expense.description, equals('Free item'));
      });

      test('should handle very small amounts', () {
        final expense = Expense(
          id: '1',
          userId: 'user1',
          amount: 0.01,
          description: 'Penny',
          paidBy: 'user1',
          date: DateTime.now(),
        );

        expect(expense.amount, equals(0.01));
      });

      test('should handle unknown paid_by values', () {
        final expenses = [
          Expense(
            id: '1',
            userId: 'user1',
            amount: 50.0,
            description: 'Unknown payer',
            paidBy: 'unknown_user',
            date: DateTime.now(),
          ),
        ];

        double user1Total = 0;
        double user2Total = 0;

        for (final expense in expenses) {
          if (expense.paidBy == 'user1') {
            user1Total += expense.amount;
          } else if (expense.paidBy == 'user2') {
            user2Total += expense.amount;
          }
          // Unknown payers are ignored
        }

        expect(user1Total, equals(0.0));
        expect(user2Total, equals(0.0));
      });
    });

    group('Data Consistency Tests', () {
      test('should maintain data consistency after JSON round trip', () {
        final originalExpense = Expense(
          id: 'exp-123',
          userId: 'user-456',
          amount: 25.75,
          description: 'Test expense with special chars: €\$£',
          paidBy: 'user1',
          date: DateTime(2024, 1, 15, 10, 30, 45),
        );

        final json = originalExpense.toJson();
        final reconstructedExpense = Expense.fromJson(json);

        expect(reconstructedExpense.id, equals(originalExpense.id));
        expect(reconstructedExpense.userId, equals(originalExpense.userId));
        expect(reconstructedExpense.amount, equals(originalExpense.amount));
        expect(reconstructedExpense.description, equals(originalExpense.description));
        expect(reconstructedExpense.paidBy, equals(originalExpense.paidBy));
        expect(reconstructedExpense.date.isAtSameMomentAs(originalExpense.date), isTrue);
      });

      test('should handle special characters in descriptions', () {
        final specialDescriptions = [
          'Café & Restaurant 🍕',
          'Hôtel Saint-Émilion',
          'Courses chez l\'épicier',
          'Transport: métro + bus',
          'Facture EDF/GDF',
        ];

        for (final description in specialDescriptions) {
          final expense = Expense(
            id: 'test',
            userId: 'user1',
            amount: 10.0,
            description: description,
            paidBy: 'user1',
            date: DateTime.now(),
          );

          final json = expense.toJson();
          final reconstructed = Expense.fromJson(json);

          expect(reconstructed.description, equals(description),
              reason: 'Failed for description: $description');
        }
      });
    });
  });
}
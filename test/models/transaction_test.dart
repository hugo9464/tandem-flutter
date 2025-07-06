import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('should create Transaction from valid JSON', () {
      final json = {
        'id': 'txn-123',
        'accountId': 'acc-456',
        'amount': 100.0,
        'currency': 'EUR',
        'date': '2024-01-15T10:30:00Z',
        'description': 'Test transaction',
        'type': 'DEBIT',
        'status': 'COMPLETED',
        'reference': 'REF-123',
        'category': 'food',
        'metadata': {'key': 'value'},
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, equals('txn-123'));
      expect(transaction.accountId, equals('acc-456'));
      expect(transaction.amount, equals(100.0));
      expect(transaction.currency, equals('EUR'));
      expect(transaction.description, equals('Test transaction'));
      expect(transaction.type, equals(TransactionType.debit));
      expect(transaction.status, equals(TransactionStatus.completed));
      expect(transaction.reference, equals('REF-123'));
      expect(transaction.category, equals('food'));
      expect(transaction.metadata, equals({'key': 'value'}));
    });

    test('should handle all transaction types', () {
      final debitJson = {'type': 'DEBIT'};
      final creditJson = {'type': 'CREDIT'};

      expect(TransactionType.values.length, equals(2));
      expect(TransactionType.debit.toString(), contains('debit'));
      expect(TransactionType.credit.toString(), contains('credit'));
    });

    test('should handle all transaction statuses', () {
      expect(TransactionStatus.values.length, equals(4));
      expect(TransactionStatus.pending.toString(), contains('pending'));
      expect(TransactionStatus.completed.toString(), contains('completed'));
      expect(TransactionStatus.failed.toString(), contains('failed'));
      expect(TransactionStatus.cancelled.toString(), contains('cancelled'));
    });

    test('should create TransactionFilters', () {
      final filters = TransactionFilters(
        dateFrom: DateTime(2024, 1, 1),
        dateTo: DateTime(2024, 1, 31),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        search: 'test',
        accountId: 'acc-123',
        minAmount: 10.0,
        maxAmount: 1000.0,
      );

      expect(filters.dateFrom, isA<DateTime>());
      expect(filters.dateTo, isA<DateTime>());
      expect(filters.type, equals(TransactionType.debit));
      expect(filters.status, equals(TransactionStatus.completed));
      expect(filters.search, equals('test'));
      expect(filters.accountId, equals('acc-123'));
      expect(filters.minAmount, equals(10.0));
      expect(filters.maxAmount, equals(1000.0));
    });

    test('should create TransactionResponse', () {
      final transactions = [
        Transaction(
          id: 'txn-1',
          accountId: 'acc-1',
          amount: 50.0,
          currency: 'EUR',
          date: DateTime.now(),
          description: 'Test 1',
          type: TransactionType.debit,
          status: TransactionStatus.completed,
        ),
      ];

      final response = TransactionResponse(
        data: transactions,
        page: 1,
        limit: 20,
        total: 1,
        totalPages: 1,
      );

      expect(response.data.length, equals(1));
      expect(response.page, equals(1));
      expect(response.limit, equals(20));
      expect(response.total, equals(1));
      expect(response.totalPages, equals(1));
    });

    test('should convert TransactionResponse to JSON and back', () {
      final response = TransactionResponse(
        data: [],
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
      );

      final json = response.toJson();
      final fromJson = TransactionResponse.fromJson(json);

      expect(fromJson.page, equals(response.page));
      expect(fromJson.limit, equals(response.limit));
      expect(fromJson.total, equals(response.total));
      expect(fromJson.totalPages, equals(response.totalPages));
    });
  });
}
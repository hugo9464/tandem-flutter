import 'dart:math';
import '../models/account.dart';
import '../models/transaction.dart';

class MockDataService {
  static final _random = Random();
  
  static final List<Account> _mockAccounts = [
    Account(
      id: 'acc_001',
      name: 'Compte Courant Principal',
      iban: 'ES7921000813610123456789',
      bic: 'CAIXESBBXXX',
      balance: 2543.67,
      currency: 'EUR',
      type: 'CHECKING',
    ),
    Account(
      id: 'acc_002',
      name: 'Compte Épargne',
      iban: 'ES7921000813610987654321',
      bic: 'CAIXESBBXXX',
      balance: 15678.90,
      currency: 'EUR',
      type: 'SAVINGS',
    ),
    Account(
      id: 'acc_003',
      name: 'Compte Professionnel',
      iban: 'ES7921000813610111222333',
      bic: 'CAIXESBBXXX',
      balance: 45321.15,
      currency: 'EUR',
      type: 'BUSINESS',
    ),
  ];

  static List<Transaction> _generateMockTransactions(String accountId) {
    final transactions = <Transaction>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 50; i++) {
      final daysAgo = _random.nextInt(90);
      final isCredit = _random.nextBool();
      final amount = (_random.nextDouble() * 1000).toDouble();
      
      transactions.add(Transaction(
        id: 'txn_${accountId}_$i',
        accountId: accountId,
        amount: isCredit ? amount : -amount,
        currency: 'EUR',
        date: now.subtract(Duration(days: daysAgo)),
        description: _getRandomDescription(isCredit),
        type: isCredit ? TransactionType.credit : TransactionType.debit,
        status: _getRandomStatus(),
        reference: 'REF${_random.nextInt(999999).toString().padLeft(6, '0')}',
        category: _getRandomCategory(),
        metadata: {
          'merchant': _getRandomMerchant(),
          'location': _getRandomLocation(),
        },
      ));
    }
    
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  static String _getRandomDescription(bool isCredit) {
    final creditDescriptions = [
      'Paiement de salaire',
      'Virement de John Doe',
      'Remboursement - Achat en ligne',
      'Dépôt d\'espèces',
      'Retour d\'investissement',
      'Paiement freelance',
      'Remboursement d\'impôts',
    ];
    
    final debitDescriptions = [
      'Achat en épicerie',
      'Paiement restaurant',
      'Achat en ligne',
      'Facture de services publics',
      'Retrait DAB',
      'Service d\'abonnement',
      'Station essence',
      'Café',
      'Pharmacie',
      'Transport - Uber',
    ];
    
    final list = isCredit ? creditDescriptions : debitDescriptions;
    return list[_random.nextInt(list.length)];
  }

  static TransactionStatus _getRandomStatus() {
    final statuses = TransactionStatus.values;
    final weights = [5, 85, 5, 5]; // pending, completed, failed, cancelled
    final totalWeight = weights.reduce((a, b) => a + b);
    final randomValue = _random.nextInt(totalWeight);
    
    var currentWeight = 0;
    for (int i = 0; i < statuses.length; i++) {
      currentWeight += weights[i];
      if (randomValue < currentWeight) {
        return statuses[i];
      }
    }
    return TransactionStatus.completed;
  }

  static String _getRandomCategory() {
    final categories = [
      'Alimentation et Restaurant',
      'Achats',
      'Transport',
      'Factures et Services',
      'Divertissement',
      'Santé',
      'Revenus',
      'Virement',
      'Autre',
    ];
    return categories[_random.nextInt(categories.length)];
  }

  static String _getRandomMerchant() {
    final merchants = [
      'Walmart',
      'Amazon',
      'Starbucks',
      'Shell Gas',
      'Netflix',
      'Uber',
      'Target',
      'McDonalds',
      'CVS Pharmacy',
      'Whole Foods',
    ];
    return merchants[_random.nextInt(merchants.length)];
  }

  static String _getRandomLocation() {
    final locations = [
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Phoenix, AZ',
      'Philadelphia, PA',
      'San Antonio, TX',
      'San Diego, CA',
      'Dallas, TX',
      'Miami, FL',
    ];
    return locations[_random.nextInt(locations.length)];
  }

  // API Methods
  Future<List<Account>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockAccounts;
  }

  Future<Account?> getAccount(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockAccounts.firstWhere(
      (account) => account.id == accountId,
      orElse: () => throw Exception('Account not found'),
    );
  }

  Future<double> getAccountBalance(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final account = await getAccount(accountId);
    return account?.balance ?? 0.0;
  }

  Future<TransactionResponse> getTransactions({
    required int page,
    required int limit,
    TransactionFilters? filters,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<Transaction> allTransactions = [];
    
    if (filters?.accountId != null) {
      allTransactions = _generateMockTransactions(filters!.accountId!);
    } else {
      for (final account in _mockAccounts) {
        allTransactions.addAll(_generateMockTransactions(account.id));
      }
    }
    
    // Apply filters
    var filteredTransactions = allTransactions.where((transaction) {
      if (filters == null) return true;
      
      if (filters.dateFrom != null && transaction.date.isBefore(filters.dateFrom!)) {
        return false;
      }
      
      if (filters.dateTo != null && transaction.date.isAfter(filters.dateTo!)) {
        return false;
      }
      
      if (filters.type != null && transaction.type != filters.type) {
        return false;
      }
      
      if (filters.status != null && transaction.status != filters.status) {
        return false;
      }
      
      if (filters.search != null && filters.search!.isNotEmpty) {
        final searchLower = filters.search!.toLowerCase();
        return transaction.description.toLowerCase().contains(searchLower) ||
               transaction.reference?.toLowerCase().contains(searchLower) == true ||
               transaction.category?.toLowerCase().contains(searchLower) == true;
      }
      
      if (filters.minAmount != null && transaction.amount.abs() < filters.minAmount!) {
        return false;
      }
      
      if (filters.maxAmount != null && transaction.amount.abs() > filters.maxAmount!) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort by date (newest first)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
    
    // Paginate
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedTransactions = filteredTransactions.sublist(
      startIndex,
      endIndex > filteredTransactions.length ? filteredTransactions.length : endIndex,
    );
    
    return TransactionResponse(
      data: paginatedTransactions,
      page: page,
      limit: limit,
      total: filteredTransactions.length,
      totalPages: (filteredTransactions.length / limit).ceil(),
    );
  }
}
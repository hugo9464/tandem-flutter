import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/gocardless_service.dart';
import '../../models/gocardless_models.dart';

class BankTransactionsScreen extends StatefulWidget {
  final BankAccount account;
  final BankInstitution? institution;

  const BankTransactionsScreen({
    super.key,
    required this.account,
    this.institution,
  });

  @override
  State<BankTransactionsScreen> createState() => _BankTransactionsScreenState();
}

class _BankTransactionsScreenState extends State<BankTransactionsScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _amountFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  Future<void> _fetchTransactions() async {
    final service = Provider.of<GoCardlessService>(context, listen: false);
    await service.fetchTransactions(widget.account.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: Consumer<GoCardlessService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des transactions...'),
                ],
              ),
            );
          }

          if (service.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      service.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchTransactions,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final transactions = service.transactions;

          return Column(
            children: [
              // En-tête avec info compte
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.institution != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.institution!.logo,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.account.name ?? 'Compte',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _formatIban(widget.account.iban),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${transactions.length} transaction${transactions.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des transactions
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune transaction',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucune transaction trouvée pour ce compte.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return _TransactionTile(
                            transaction: transaction,
                            dateFormat: _dateFormat,
                            amountFormat: _amountFormat,
                            isPending: service.isTransactionPending(transaction),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatIban(String? iban) {
    if (iban == null || iban.isEmpty) return 'Pas d\'IBAN';
    if (iban.length <= 4) return iban;
    return '${iban.substring(0, 4)} •••• •••• ${iban.substring(iban.length - 4)}';
  }
}

class _TransactionTile extends StatelessWidget {
  final GoCardlessTransaction transaction;
  final DateFormat dateFormat;
  final NumberFormat amountFormat;
  final bool isPending;

  const _TransactionTile({
    required this.transaction,
    required this.dateFormat,
    required this.amountFormat,
    required this.isPending,
  });

  bool get _isCredit {
    final amount = double.tryParse(transaction.transactionAmount.amount) ?? 0;
    return amount >= 0;
  }

  String get _displayName {
    if (!_isCredit && transaction.creditorName != null) {
      return transaction.creditorName!;
    }
    if (_isCredit && transaction.debtorName != null) {
      return transaction.debtorName!;
    }
    return 'Transaction';
  }

  String get _description {
    final desc = transaction.description;
    if (desc != null && desc.isNotEmpty) {
      return desc;
    }
    return _isCredit ? 'Crédit' : 'Débit';
  }

  DateTime? get _date {
    final dateStr = transaction.bookingDate ?? transaction.valueDate;
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(transaction.transactionAmount.amount) ?? 0;
    final absAmount = amount.abs();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isCredit
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: _isCredit ? Colors.green[600] : Colors.red[600],
          ),
        ),
        title: Text(
          _displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_date != null || isPending) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (_date != null)
                    Text(
                      dateFormat.format(_date!),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  if (isPending) ...[
                    if (_date != null) const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Text(
                        'En attente',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_isCredit ? '+' : '-'}${absAmount.toStringAsFixed(2)} ${transaction.transactionAmount.currency}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: _isCredit ? Colors.green[600] : Colors.red[600],
              ),
            ),
            if (transaction.bankTransactionCode != null)
              Text(
                transaction.bankTransactionCode!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
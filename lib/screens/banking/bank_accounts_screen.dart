import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gocardless_service.dart';
import '../../models/gocardless_models.dart';
import 'bank_transactions_screen.dart';

class BankAccountsScreen extends StatefulWidget {
  final BankInstitution institution;
  final String requisitionId;

  const BankAccountsScreen({
    super.key,
    required this.institution,
    required this.requisitionId,
  });

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAccounts();
    });
  }

  Future<void> _fetchAccounts() async {
    final service = Provider.of<GoCardlessService>(context, listen: false);
    await service.fetchAccounts(widget.requisitionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos comptes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  Text('Récupération de vos comptes...'),
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
                    onPressed: _fetchAccounts,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final accounts = service.accounts;

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun compte trouvé',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun compte n\'a été trouvé pour cette banque.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // En-tête avec info banque
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.institution.logo,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.institution.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${accounts.length} compte${accounts.length > 1 ? 's' : ''} trouvé${accounts.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                    ),
                  ],
                ),
              ),

              // Liste des comptes
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _AccountTile(
                      account: account,
                      onTap: () => _viewTransactions(account),
                    );
                  },
                ),
              ),
              
              // Bouton pour utiliser ces comptes
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'accounts': accounts,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Utiliser ces comptes'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _viewTransactions(BankAccount account) {
    // Retourner à l'écran précédent avec les comptes
    final accounts = Provider.of<GoCardlessService>(context, listen: false).accounts;
    Navigator.of(context).pop({
      'accounts': accounts,
    });
  }
}

class _AccountTile extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.onTap,
  });

  String _formatIban(String? iban) {
    if (iban == null || iban.isEmpty) return 'Pas d\'IBAN';
    if (iban.length <= 4) return iban;
    return '${iban.substring(0, 4)} •••• •••• ${iban.substring(iban.length - 4)}';
  }

  String _getAccountTypeDisplay() {
    if (account.accountType != null) {
      return account.accountType!;
    }
    if (account.cashAccountType != null) {
      return account.cashAccountType!;
    }
    return 'Compte';
  }

  String? _getBalance() {
    if (account.balances?.balances != null && account.balances!.balances!.isNotEmpty) {
      final balance = account.balances!.balances!.first;
      return '${balance.balanceAmount.amount} ${balance.balanceAmount.currency}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name ?? _getAccountTypeDisplay(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatIban(account.iban),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (account.ownerName != null)
              Text(
                'Titulaire: ${account.ownerName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            if (_getBalance() != null) ...[
              const SizedBox(height: 4),
              Text(
                'Solde: ${_getBalance()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/tandem.dart';
import '../services/supabase_service.dart';
import '../services/preferences_service.dart';
import '../services/tandem_service.dart';
import '../widgets/loading_animation.dart';

class TransactionsScreen extends StatefulWidget {
  final String accountId;
  final String accountName;

  const TransactionsScreen({
    Key? key,
    required this.accountId,
    required this.accountName,
  }) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  
  // Current account info
  late String _currentAccountId;
  late String _currentAccountName;
  
  // Filters
  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _currentAccountId = widget.accountId;
    _currentAccountName = widget.accountName;
    _loadTransactions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  TransactionFilters get _currentFilters => TransactionFilters(
    accountId: _currentAccountId,
    type: _selectedType,
    status: _selectedStatus,
    dateFrom: _dateRange?.start,
    dateTo: _dateRange?.end,
    search: _searchController.text.isEmpty ? null : _searchController.text,
  );

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _transactions = [];
    });

    try {
      final response = await SupabaseService.getTransactions(
        accountId: _currentAccountId,
        page: _currentPage,
        limit: _limit,
        filters: _currentFilters,
      );
      
      setState(() {
        _transactions = response.data;
        _hasMore = response.page < response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur transactions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final response = await SupabaseService.getTransactions(
        accountId: _currentAccountId,
        page: _currentPage,
        limit: _limit,
        filters: _currentFilters,
      );
      
      setState(() {
        _transactions.addAll(response.data);
        _hasMore = response.page < response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentPage--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur pagination: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        dateRange: _dateRange,
        onApply: (type, status, dateRange) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _dateRange = dateRange;
          });
          _loadTransactions();
        },
      ),
    );
  }

  Future<void> _showAccountSwitcher() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get accounts
      final accounts = await SupabaseService.getAccounts();
      
      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (accounts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun compte bancaire trouvé'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show account selection
      if (mounted) {
        final result = await showDialog<Account>(
          context: context,
          builder: (context) => _AccountSwitcherDialog(
            accounts: accounts,
            currentAccountId: _currentAccountId,
          ),
        );

        if (result != null && mounted) {
          final selectedAccount = result;
          
          // Always set the selected account as main
          final prefsService = PreferencesService();
          await prefsService.setMainAccount(selectedAccount.iban);
          
          // Update current account and reload transactions
          setState(() {
            _currentAccountId = selectedAccount.id;
            _currentAccountName = selectedAccount.name;
          });
          
          _loadTransactions();
        }
      }
    } catch (e) {
      // Close loading if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddToTandemDialog(Transaction transaction) async {
    if (transaction.type == TransactionType.credit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Les crédits ne peuvent pas être ajoutés comme dépenses'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get user's tandems
      final tandems = await TandemService.getUserTandems();
      
      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (tandems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Vous n\'êtes membre d\'aucun tandem'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show tandem selection dialog
      if (mounted) {
        final selectedTandem = await showDialog<Tandem>(
          context: context,
          builder: (context) => _TandemSelectionDialog(
            tandems: tandems,
            transaction: transaction,
          ),
        );

        if (selectedTandem != null && mounted) {
          await _addTransactionToTandem(transaction, selectedTandem);
        }
      }
    } catch (e) {
      // Close loading if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addTransactionToTandem(Transaction transaction, Tandem tandem) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Add transaction as expense
      await TandemService.addTransactionAsExpense(
        tandemId: tandem.id,
        transaction: transaction,
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Transaction ajoutée au tandem "${tandem.name}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAccountName),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _showAccountSwitcher,
            tooltip: 'Changer de compte',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des transactions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _loadTransactions(),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Appuyez longuement sur une transaction pour l\'ajouter à un tandem',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTransactions,
              child: _isLoading && _transactions.isEmpty
                  ? const Center(
                      child: LoadingAnimation(
                        message: 'Chargement des transactions...',
                        size: 60,
                      ),
                    )
                  : _transactions.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune transaction trouvée',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tirez vers le bas pour actualiser',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _transactions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _transactions.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: PulsingDots(),
                            ),
                          );
                        }
                        return _TransactionTile(
                          transaction: _transactions[index],
                          onAddToTandem: _showAddToTandemDialog,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction)? onAddToTandem;

  const _TransactionTile({
    required this.transaction,
    this.onAddToTandem,
  });

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = widget.transaction.type == TransactionType.credit;
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(
              bottom: 8,
              left: _slideAnimation.value,
              right: _slideAnimation.value,
            ),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _controller.forward().then((_) {
                    _controller.reverse();
                  });
                },
                onLongPress: widget.onAddToTandem != null
                    ? () => widget.onAddToTandem!(widget.transaction)
                    : null,
                onTapDown: (_) => _controller.forward(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
                  title: Text(
                    widget.transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateFormat.format(widget.transaction.date)),
                      if (widget.transaction.category != null)
                        Text(
                          widget.transaction.category!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? '+' : ''}${widget.transaction.currency} ${widget.transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      _StatusChip(status: widget.transaction.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TransactionStatus status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case TransactionStatus.completed:
        color = Colors.green;
        text = 'Terminé';
        break;
      case TransactionStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case TransactionStatus.failed:
        color = Colors.red;
        text = 'Échoué';
        break;
      case TransactionStatus.cancelled:
        color = Colors.grey;
        text = 'Annulé';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final DateTimeRange? dateRange;
  final Function(TransactionType?, TransactionStatus?, DateTimeRange?) onApply;

  const _FilterDialog({
    this.selectedType,
    this.selectedStatus,
    this.dateRange,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  TransactionType? _type;
  TransactionStatus? _status;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _status = widget.selectedStatus;
    _dateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer les Transactions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Type filter
          Text('Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _type == null,
                onSelected: (selected) {
                  setState(() => _type = null);
                },
              ),
              ChoiceChip(
                label: const Text('Crédit'),
                selected: _type == TransactionType.credit,
                onSelected: (selected) {
                  setState(() => _type = selected ? TransactionType.credit : null);
                },
              ),
              ChoiceChip(
                label: const Text('Débit'),
                selected: _type == TransactionType.debit,
                onSelected: (selected) {
                  setState(() => _type = selected ? TransactionType.debit : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Status filter
          Text('Statut', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _status == null,
                onSelected: (selected) {
                  setState(() => _status = null);
                },
              ),
              ...TransactionStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(status.name.toUpperCase()),
                  selected: _status == status,
                  onSelected: (selected) {
                    setState(() => _status = selected ? status : null);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date range
          Text('Plage de dates', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final yesterday = DateTime(now.year, now.month, now.day - 1);
              final range = await showDateRangePicker(
                context: context,
                firstDate: yesterday.subtract(const Duration(days: 365)),
                lastDate: yesterday,
                initialDateRange: _dateRange,
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _dateRange == null
                  ? 'Sélectionner une plage de dates'
                  : '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}',
            ),
          ),
          const SizedBox(height: 24),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _type = null;
                    _status = null;
                    _dateRange = null;
                  });
                },
                child: const Text('Effacer'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(_type, _status, _dateRange);
                  Navigator.pop(context);
                },
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountSwitcherDialog extends StatefulWidget {
  final List<Account> accounts;
  final String currentAccountId;

  const _AccountSwitcherDialog({
    required this.accounts,
    required this.currentAccountId,
  });

  @override
  State<_AccountSwitcherDialog> createState() => _AccountSwitcherDialogState();
}

class _AccountSwitcherDialogState extends State<_AccountSwitcherDialog> {
  String? _currentMainAccount;

  @override
  void initState() {
    super.initState();
    _loadCurrentMainAccount();
  }

  Future<void> _loadCurrentMainAccount() async {
    final prefsService = PreferencesService();
    final mainAccount = await prefsService.getMainAccount();
    setState(() {
      _currentMainAccount = mainAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Changer de compte',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                final isMainAccount = account.iban == _currentMainAccount;
                final isCurrentAccount = account.id == widget.currentAccountId;
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMainAccount 
                          ? Theme.of(context).primaryColor 
                          : null,
                      child: Icon(
                        Icons.account_balance,
                        color: isMainAccount ? Colors.white : null,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(account.name)),
                        if (isMainAccount) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Principal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isCurrentAccount)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Actuel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(account.iban),
                    trailing: Text(
                      '€${account.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(account);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Le compte sélectionné deviendra votre compte principal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class _TandemSelectionDialog extends StatelessWidget {
  final List<Tandem> tandems;
  final Transaction transaction;

  const _TandemSelectionDialog({
    required this.tandems,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDebitTransaction = transaction.type == TransactionType.debit;
    
    return AlertDialog(
      title: Text(
        'Ajouter au tandem',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDebitTransaction ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDebitTransaction ? Colors.red[200]! : Colors.green[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDebitTransaction ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isDebitTransaction ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${transaction.currency} ${transaction.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDebitTransaction ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un tandem :',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tandems.length,
              itemBuilder: (context, index) {
                final tandem = tandems[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.favorite,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tandem.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('Code: ${tandem.code}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).pop(tandem);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/tandem.dart';
import '../../models/expense.dart';
import '../../models/account.dart';
import '../../models/gocardless_models.dart';
import '../../services/tandem_service.dart';
import '../../services/auth_service.dart';
import '../../services/gocardless_service.dart';
import '../../widgets/loading_animation.dart';
import '../banking/bank_selection_screen.dart';
import '../banking/bank_transactions_screen.dart';
import 'tandem_selection_screen.dart';
import '../../services/preferences_service.dart';

class TandemDetailScreen extends StatefulWidget {
  final String tandemId;

  const TandemDetailScreen({super.key, required this.tandemId});

  @override
  State<TandemDetailScreen> createState() => _TandemDetailScreenState();
}

class _TandemDetailScreenState extends State<TandemDetailScreen> {
  Tandem? _tandem;
  List<TandemMember> _members = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTandemData();
  }

  Future<void> _loadTandemData() async {
    setState(() => _isLoading = true);
    try {
      final tandem = await TandemService.getTandem(widget.tandemId);
      final members = await TandemService.getTandemMembers(widget.tandemId);
      final expenses = await TandemService.getTandemExpenses(widget.tandemId);

      if (mounted) {
        setState(() {
          _tandem = tandem;
          _members = members;
          _expenses = expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  double get _totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _myExpenses {
    final currentUserId = AuthService.currentUser?.id;
    return _expenses
        .where((expense) => expense.paidBy == currentUserId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _myShare {
    if (_members.isEmpty) return 0.0;
    return _totalExpenses / _members.length;
  }

  double get _balance {
    return _myExpenses - _myShare;
  }

  Future<void> _showTransactions() async {
    // Code existant pour les transactions...
  }

  Future<void> _showAddExpenseDialog() async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedPaidBy = AuthService.currentUser?.id;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nouvelle dépense',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A202C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ajoutez une nouvelle dépense au tandem',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description Field
                    _buildModernTextField(
                      controller: descriptionController,
                      label: 'Description',
                      icon: Icons.description_outlined,
                      hint: 'Restaurant, Courses, Essence...',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Une description est requise';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Amount Field
                    _buildModernTextField(
                      controller: amountController,
                      label: 'Montant (€)',
                      icon: Icons.euro_outlined,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Un montant est requis';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payer Selection
                    _buildModernDropdown(
                      selectedPaidBy: selectedPaidBy,
                      onChanged: (value) {
                        setState(() {
                          selectedPaidBy = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Annuler',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;

                                    setState(() => isLoading = true);
                                    
                                    // Capture context values before async operations
                                    final navigator = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(context);
                                    final primaryColor = Theme.of(context).colorScheme.primary;

                                    try {
                                      final amount = double.parse(amountController.text.trim());

                                      await TandemService.addExpense(
                                        tandemId: widget.tandemId,
                                        amount: amount,
                                        description: descriptionController.text.trim(),
                                        paidBy: selectedPaidBy!,
                                      );

                                      if (mounted) {
                                        navigator.pop();
                                        _loadTandemData();
                                        
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Dépense ajoutée avec succès !',
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                            ),
                                            backgroundColor: primaryColor,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erreur: ${e.toString()}',
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                            ),
                                            backgroundColor: Colors.red.shade400,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => isLoading = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Ajouter la dépense',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String? selectedPaidBy,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payé par',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedPaidBy,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A202C),
          ),
          decoration: InputDecoration(
            hintText: 'Sélectionner une personne',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          items: _members.map((member) {
            final currentUserId = AuthService.currentUser?.id;
            final isCurrentUser = member.userId == currentUserId;
            final displayName = isCurrentUser
                ? 'Vous'
                : (member.email?.split('@')[0] ?? 'Utilisateur inconnu');

            return DropdownMenuItem<String>(
              value: member.userId,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCurrentUser ? Icons.person : Icons.person_outline,
                      color: isCurrentUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Sélectionnez qui a payé';
            }
            return null;
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _tandem?.name ?? 'Tandem',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF718096)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: LoadingAnimation(
                message: 'Chargement du tandem...',
                size: 60,
              ),
            )
          : _buildOverviewTab(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Ajouter',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadTandemData,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildRecentExpenses(),
            const SizedBox(height: 80), // Espace pour le FAB
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final isPositive = _balance >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)]
              : [Colors.red.shade400, Colors.red.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPositive 
                ? Theme.of(context).colorScheme.primary 
                : Colors.red.shade400).withValues(alpha: 0.25),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre Balance',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${isPositive ? '+' : ''}€${_balance.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPositive
                ? 'Vous avez payé plus que votre part'
                : 'Vous devez de l\'argent au groupe',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Dépenses',
                '€${_totalExpenses.toStringAsFixed(2)}',
                Icons.receipt_long,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Vos Dépenses',
                '€${_myExpenses.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Votre Part',
                '€${_myShare.toStringAsFixed(2)}',
                Icons.pie_chart,
                Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Membres',
                '${_members.length}',
                Icons.people,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses() {
    final recentExpenses = _expenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dépenses Récentes',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A202C),
              ),
            ),
            if (_expenses.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentExpenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune dépense',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Commencez par ajouter une dépense',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: recentExpenses.asMap().entries.map((entry) {
                final index = entry.key;
                final expense = entry.value;
                final isLast = index == recentExpenses.length - 1;
                return _buildExpenseCard(expense, isLast);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense, bool isLast) {
    final isMyExpense = expense.paidBy == AuthService.currentUser?.id;
    final payer = _members.firstWhere(
      (member) => member.userId == expense.paidBy,
      orElse: () => TandemMember(
        id: '',
        tandemId: '',
        userId: expense.paidBy,
        email: 'Unknown',
        role: 'member',
        joinedAt: DateTime.now(),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isMyExpense
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.euro,
                color: isMyExpense
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payé par ${isMyExpense ? 'vous' : (payer.email?.split('@')[0] ?? 'Utilisateur inconnu')}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '€${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isMyExpense
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF1A202C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
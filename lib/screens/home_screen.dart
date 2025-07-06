import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../services/supabase_service.dart';
import '../widgets/network_status.dart';
import '../widgets/loading_animation.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Account> _accounts = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadAccounts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await SupabaseService.getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des comptes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NetworkStatusWidget(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAccounts,
              child: _isLoading
                  ? const Center(
                      child: LoadingAnimation(
                        message: 'Chargement des comptes...',
                        size: 60,
                      ),
                    )
                  : _accounts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun compte trouvé',
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
                      : AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _accounts.length,
                              itemBuilder: (context, index) {
                                final account = _accounts[index];
                                return AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(
                                        (index * 0.1).clamp(0.0, 1.0),
                                        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                                        curve: Curves.easeOutBack,
                                      ),
                                    ));
                                    
                                    return SlideTransition(
                                      position: slideAnimation,
                                      child: FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: _AccountCard(
                                          account: account,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                    TransactionsScreen(
                                                  accountId: account.id,
                                                  accountName: account.name,
                                                ),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  const begin = Offset(1.0, 0.0);
                                                  const end = Offset.zero;
                                                  const curve = Curves.easeInOut;
                                                  
                                                  var tween = Tween(begin: begin, end: end).chain(
                                                    CurveTween(curve: curve),
                                                  );
                                                  
                                                  return SlideTransition(
                                                    position: animation.drive(tween),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration: const Duration(milliseconds: 300),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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

class _AccountCard extends StatefulWidget {
  final Account account;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.onTap,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'shared':
        return Icons.favorite;
      default:
        return Icons.account_balance;
    }
  }

  Color _getAccountColor(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return const Color(0xFF4ECDC4);
      case 'savings':
        return const Color(0xFFFFA726);
      case 'shared':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF6C7293);
    }
  }

  String _getAccountTypeInFrench(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return 'Courant';
      case 'savings':
        return 'Épargne';
      case 'shared':
        return 'Partagé';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _scaleController.forward().then((_) {
                    _scaleController.reverse();
                    widget.onTap();
                  });
                },
                onTapDown: (_) => _scaleController.forward(),
                onTapCancel: () => _scaleController.reverse(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getAccountColor(widget.account.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAccountIcon(widget.account.type),
                        color: _getAccountColor(widget.account.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.account.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getAccountColor(widget.account.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getAccountTypeInFrench(widget.account.type),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _getAccountColor(widget.account.type),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solde Actuel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    Text(
                      '${widget.account.currency} ${widget.account.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: widget.account.balance >= 0 
                            ? const Color(0xFF38A169) 
                            : const Color(0xFFE53E3E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 16,
                      color: const Color(0xFF718096),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'IBAN: ${widget.account.iban}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF718096),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
        ));
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../widgets/network_status.dart';
import 'transactions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
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
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const NetworkStatusWidget(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: const Color(0xFF4ECDC4),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mon Compte',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        TextButton.icon(
                          onPressed: () => _showSignOutDialog(context),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Déconnexion'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showForceSignOutDialog(context),
                          icon: const Icon(Icons.warning, size: 18),
                          label: const Text('Déconnexion d\'urgence'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AuthService.currentUser?.email ?? 'Utilisateur connecté',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      color: const Color(0xFF4ECDC4),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Comptes Bancaires',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez vos comptes bancaires connectés',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAccounts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _accounts.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun compte trouvé',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        return _AccountCard(
                          account: account,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionsScreen(
                                  accountId: account.id,
                                  accountName: account.name,
                                ),
                              ),
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performSignOut(context, forceLocal: false);
              },
              child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showForceSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion d\'urgence'),
          content: const Text(
            'Cette option force la déconnexion locale même si le serveur est indisponible. '
            'Utilisez uniquement si la déconnexion normale ne fonctionne pas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performSignOut(context, forceLocal: true);
              },
              child: const Text('Forcer la déconnexion', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSignOut(BuildContext context, {required bool forceLocal}) async {
    try {
      final result = await AuthService.signOut(forceLocal: forceLocal);
      
      if (result.isSuccess) {
        String message;
        Color backgroundColor;
        
        switch (result.type) {
          case SignOutType.success:
            message = 'Déconnexion réussie';
            backgroundColor = Colors.green;
            break;
          case SignOutType.successLocal:
            message = 'Déconnexion locale effectuée';
            backgroundColor = Colors.orange;
            break;
          case SignOutType.errorButLocalSuccess:
            message = 'Déconnexion locale effectuée (erreur serveur: ${result.errorMessage})';
            backgroundColor = Colors.orange;
            break;
          case SignOutType.error:
            message = 'Erreur de déconnexion: ${result.errorMessage}';
            backgroundColor = Colors.red;
            break;
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur critique: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.onTap,
  });

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
    return Container(
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
          onTap: onTap,
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
                        color: _getAccountColor(account.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAccountIcon(account.type),
                        color: _getAccountColor(account.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
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
                              color: _getAccountColor(account.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getAccountTypeInFrench(account.type),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _getAccountColor(account.type),
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
                      '${account.currency} ${account.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: account.balance >= 0 
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
                        'IBAN: ${account.iban}',
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
    );
  }
}
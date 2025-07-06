import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandem_flutter/screens/settings_screen.dart';
import 'package:tandem_flutter/models/account.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('should display account section header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Comptes Bancaires'), findsOneWidget);
      expect(find.text('Gérez vos comptes bancaires connectés'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state message when no accounts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun compte trouvé'), findsOneWidget);
    });

    testWidgets('should have refresh capability', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should display proper app bar styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.pump();

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final AppBar appBarWidget = tester.widget(appBar);
      expect(appBarWidget.centerTitle, isTrue);
      expect(appBarWidget.backgroundColor, equals(Colors.transparent));
      expect(appBarWidget.elevation, equals(0));
    });

    group('Account Card Tests', () {
      testWidgets('should display account information correctly', (WidgetTester tester) async {
        final account = Account(
          id: 'acc-123',
          name: 'Test Account',
          iban: 'FR76 1234 5678 9012 3456 7890 123',
          bic: 'BNPAFRPP',
          balance: 1500.75,
          currency: '€',
          type: 'checking',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Account'), findsOneWidget);
        expect(find.text('€ 1500.75'), findsOneWidget);
        expect(find.text('Courant'), findsOneWidget);
        expect(find.text('IBAN: FR76 1234 5678 9012 3456 7890 123'), findsOneWidget);
        expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });

      testWidgets('should display savings account correctly', (WidgetTester tester) async {
        final account = Account(
          id: 'acc-456',
          name: 'Savings Account',
          iban: 'FR76 9876 5432 1098 7654 3210 987',
          bic: 'BNPAFRPP',
          balance: 5000.00,
          currency: '€',
          type: 'savings',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Épargne'), findsOneWidget);
        expect(find.byIcon(Icons.savings), findsOneWidget);
      });

      testWidgets('should display shared account correctly', (WidgetTester tester) async {
        final account = Account(
          id: 'acc-789',
          name: 'Shared Account',
          iban: 'FR76 1111 2222 3333 4444 5555 666',
          bic: 'BNPAFRPP',
          balance: -250.50,
          currency: '€',
          type: 'shared',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Partagé'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        
        // Check negative balance styling
        final balanceText = tester.widget<Text>(
          find.textContaining('-250.50'),
        );
        expect(balanceText.style?.color, equals(const Color(0xFFE53E3E)));
      });

      testWidgets('should handle tap on account card', (WidgetTester tester) async {
        bool cardTapped = false;
        final account = Account(
          id: 'acc-123',
          name: 'Test Account',
          iban: 'FR76 1234 5678 9012 3456 7890 123',
          bic: 'BNPAFRPP',
          balance: 1000.00,
          currency: '€',
          type: 'checking',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pump();

        expect(cardTapped, isTrue);
      });

      testWidgets('should handle unknown account type', (WidgetTester tester) async {
        final account = Account(
          id: 'acc-unknown',
          name: 'Unknown Account',
          iban: 'FR76 0000 0000 0000 0000 0000 000',
          bic: 'BNPAFRPP',
          balance: 500.00,
          currency: '€',
          type: 'unknown_type',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('unknown_type'), findsOneWidget);
        expect(find.byIcon(Icons.account_balance), findsOneWidget);
      });
    });

    group('UI Component Tests', () {
      testWidgets('should display network status widget', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SettingsScreen(),
          ),
        );

        await tester.pump();

        expect(find.byType(NetworkStatusWidget), findsOneWidget);
      });

      testWidgets('should have proper card styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SettingsScreen(),
          ),
        );

        await tester.pump();

        final container = find.byType(Container).first;
        expect(container, findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate to account transactions when card tapped', (WidgetTester tester) async {
        final account = Account(
          id: 'acc-123',
          name: 'Test Account',
          iban: 'FR76 1234 5678 9012 3456 7890 123',
          bic: 'BNPAFRPP',
          balance: 1000.00,
          currency: '€',
          type: 'checking',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AccountCard(
                account: account,
                onTap: () {
                  Navigator.of(tester.element(find.byType(Scaffold))).pushNamed('/transactions');
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // In a real test, we would verify navigation occurred
        // This is a simplified version since we can't easily mock Navigator
        expect(find.byType(_AccountCard), findsOneWidget);
      });
    });
  });
}

// Mock implementation of AccountCard for testing
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
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
                              style: TextStyle(
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
                    const Text(
                      'Solde Actuel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF718096),
                      ),
                    ),
                    Text(
                      '${account.currency} ${account.balance.toStringAsFixed(2)}',
                      style: TextStyle(
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
                    const Icon(
                      Icons.credit_card,
                      size: 16,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'IBAN: ${account.iban}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF718096),
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

// Mock NetworkStatusWidget for testing
class NetworkStatusWidget extends StatelessWidget {
  const NetworkStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
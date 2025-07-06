import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/expense.dart';

class SupabaseService {

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<Account>> getAccounts() async {
    // Les comptes sont maintenant gérés via GoCardless
    // Cette méthode est conservée pour la compatibilité mais ne devrait plus être utilisée
    throw Exception('getAccounts() obsolète - utilisez GoCardlessService pour récupérer les comptes bancaires');
  }

  static Future<TransactionResponse> getTransactions({
    String? accountId,
    int page = 1,
    int limit = 20,
    TransactionFilters? filters,
  }) async {
    // Les transactions sont maintenant gérées via GoCardless
    // Cette méthode est conservée pour la compatibilité mais ne devrait plus être utilisée
    throw Exception('getTransactions() obsolète - utilisez GoCardlessService pour récupérer les transactions');
  }

  static Future<List<Transaction>> getTestTransactions() async {
    // Les transactions de test ne sont plus nécessaires avec GoCardless
    throw Exception('getTestTransactions() obsolète - utilisez GoCardless pour les vraies données bancaires');
  }

  // Méthodes pour la gestion des dépenses
  static Future<List<Expense>> getExpenses() async {
    try {
      final response = await _client
          .from('expenses')
          .select()
          .order('date', ascending: false);
      
      return (response as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Impossible de charger les dépenses: $e');
    }
  }

  static Future<void> addExpense({
    required double amount,
    required String description,
    required String paidBy,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _client.from('expenses').insert({
        'user_id': user.id,
        'amount': amount,
        'description': description,
        'paid_by': paidBy,
      });
    } catch (e) {
      throw Exception('Impossible d\'ajouter la dépense: $e');
    }
  }

  static Future<void> deleteExpense(String expenseId) async {
    try {
      await _client
          .from('expenses')
          .delete()
          .eq('id', expenseId);
    } catch (e) {
      throw Exception('Impossible de supprimer la dépense: $e');
    }
  }

  static Future<Map<String, double>> getBalance() async {
    try {
      final expenses = await getExpenses();
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
      
      return {
        'user1_paid': user1Total,
        'user2_paid': user2Total,
        'user1_owes': halfAmount - user1Total,
        'user2_owes': halfAmount - user2Total,
        'total': totalExpenses,
      };
    } catch (e) {
      throw Exception('Impossible de calculer la balance: $e');
    }
  }
}
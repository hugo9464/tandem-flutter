import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tandem.dart';
import '../models/expense.dart';
import '../models/transaction.dart';
import 'auth_service.dart';

class TandemService {
  static final _client = Supabase.instance.client;

  // Get current user's tandems
  static Future<List<Tandem>> getUserTandems() async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // First get tandem IDs where user is a member
      final memberResponse = await _client
          .from('tandem_members')
          .select('tandem_id')
          .eq('user_id', userId);

      if (memberResponse.isEmpty) {
        return [];
      }

      final tandemIds = (memberResponse as List)
          .map((row) => row['tandem_id'] as String)
          .toList();

      // Then get the tandems
      final response = await _client
          .from('tandems')
          .select('id, name, code, created_by, created_at, updated_at')
          .inFilter('id', tandemIds);

      return (response as List)
          .map((json) => Tandem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Impossible de charger les tandems: $e');
    }
  }

  // Get tandem by ID with members
  static Future<Tandem?> getTandemById(String tandemId) async {
    try {
      final response = await _client
          .from('tandems')
          .select()
          .eq('id', tandemId)
          .maybeSingle();

      if (response == null) return null;
      
      return Tandem.fromJson(response);
    } catch (e) {
      throw Exception('Impossible de charger le tandem: $e');
    }
  }

  // Get tandem members
  static Future<List<TandemMember>> getTandemMembers(String tandemId) async {
    try {
      // Simple approach: get members without emails for now
      final response = await _client
          .from('tandem_members')
          .select('id, tandem_id, user_id, role, joined_at')
          .eq('tandem_id', tandemId);

      return (response as List).map((memberData) {
        final memberJson = Map<String, dynamic>.from(memberData);
        // For now, just use "Membre" as email placeholder
        memberJson['email'] = 'membre@example.com';
        return TandemMember.fromJson(memberJson);
      }).toList();
    } catch (e) {
      throw Exception('Impossible de charger les membres: $e');
    }
  }

  // Create a new tandem
  static Future<Tandem> createTandem(String name) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Call the stored procedure that handles code generation and member creation
      final response = await _client
          .rpc('create_tandem_with_owner', params: {
            'p_name': name,
            'p_user_id': userId,
          });

      if (response == null || (response as List).isEmpty) {
        throw Exception('Erreur lors de la création du tandem');
      }

      return Tandem.fromJson(response[0]);
    } catch (e) {
      throw Exception('Impossible de créer le tandem: $e');
    }
  }

  // Join a tandem using code
  static Future<void> joinTandem(String code) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Find tandem by code
      final tandemResponse = await _client
          .from('tandems')
          .select('id')
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (tandemResponse == null) {
        throw Exception('Code invalide');
      }

      final tandemId = tandemResponse['id'];

      // Check if user is already a member
      final existingMember = await _client
          .from('tandem_members')
          .select('id')
          .eq('tandem_id', tandemId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('Vous êtes déjà membre de ce tandem');
      }

      // Add user as member
      await _client.from('tandem_members').insert({
        'tandem_id': tandemId,
        'user_id': userId,
        'role': 'member',
      });
    } catch (e) {
      if (e.toString().contains('Code invalide')) {
        throw Exception('Code invalide');
      } else if (e.toString().contains('déjà membre')) {
        throw Exception('Vous êtes déjà membre de ce tandem');
      }
      throw Exception('Impossible de rejoindre le tandem: $e');
    }
  }

  // Leave a tandem
  static Future<void> leaveTandem(String tandemId) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _client
          .from('tandem_members')
          .delete()
          .eq('tandem_id', tandemId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Impossible de quitter le tandem: $e');
    }
  }

  // Delete a tandem (owner only)
  static Future<void> deleteTandem(String tandemId) async {
    try {
      await _client
          .from('tandems')
          .delete()
          .eq('id', tandemId);
    } catch (e) {
      throw Exception('Impossible de supprimer le tandem: $e');
    }
  }

  // Get current user's active tandem (if any)
  static Future<Tandem?> getCurrentTandem() async {
    try {
      final tandems = await getUserTandems();
      return tandems.isNotEmpty ? tandems.first : null;
    } catch (e) {
      return null;
    }
  }

  // Get a specific tandem
  static Future<Tandem> getTandem(String tandemId) async {
    try {
      final response = await _client
          .from('tandems')
          .select()
          .eq('id', tandemId)
          .single();

      return Tandem.fromJson(response);
    } catch (e) {
      throw Exception('Impossible de charger le tandem: $e');
    }
  }

  // Get tandem expenses
  static Future<List<Expense>> getTandemExpenses(String tandemId) async {
    try {
      final response = await _client
          .from('expenses')
          .select()
          .eq('tandem_id', tandemId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Impossible de charger les dépenses: $e');
    }
  }

  // Add a new expense
  static Future<Expense> addExpense({
    required String tandemId,
    required double amount,
    required String description,
    required String paidBy,
  }) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await _client
          .from('expenses')
          .insert({
            'user_id': userId,
            'tandem_id': tandemId,
            'amount': amount,
            'description': description,
            'paid_by': paidBy,
            'date': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Impossible d\'ajouter la dépense: $e');
    }
  }

  // Add transaction as expense to tandem
  static Future<Expense> addTransactionAsExpense({
    required String tandemId,
    required Transaction transaction,
  }) async {
    try {
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // For debit transactions (expenses), use the absolute amount
      // For credit transactions, don't add them as expenses (they're income)
      if (transaction.type == TransactionType.credit) {
        throw Exception('Les crédits ne peuvent pas être ajoutés comme dépenses');
      }

      final response = await _client
          .from('expenses')
          .insert({
            'user_id': userId,
            'tandem_id': tandemId,
            'amount': transaction.amount.abs(),
            'description': transaction.description,
            'paid_by': userId, // Current user pays the expense
            'date': transaction.date.toIso8601String(),
          })
          .select()
          .single();

      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Impossible d\'ajouter la transaction au tandem: $e');
    }
  }
}
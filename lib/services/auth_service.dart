import 'package:supabase_flutter/supabase_flutter.dart';

enum SignOutType { success, successLocal, errorButLocalSuccess, error }

class SignOutResult {
  final SignOutType type;
  final String? errorMessage;

  SignOutResult._(this.type, this.errorMessage);

  factory SignOutResult.success() => SignOutResult._(SignOutType.success, null);
  factory SignOutResult.successLocal() => SignOutResult._(SignOutType.successLocal, null);
  factory SignOutResult.errorButLocalSuccess(String error) => SignOutResult._(SignOutType.errorButLocalSuccess, error);
  factory SignOutResult.error(String error) => SignOutResult._(SignOutType.error, error);

  bool get isSuccess => type == SignOutType.success || type == SignOutType.successLocal || type == SignOutType.errorButLocalSuccess;
  bool get hasError => type == SignOutType.errorButLocalSuccess || type == SignOutType.error;
  bool get isLocalOnly => type == SignOutType.successLocal || type == SignOutType.errorButLocalSuccess;
}

class AuthService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return null; // Success
      } else {
        return 'Erreur de connexion';
      }
    } catch (e) {
      return _getErrorMessage(e);
    }
  }

  static Future<String?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return null; // Success
      } else {
        return 'Erreur lors de l\'inscription';
      }
    } catch (e) {
      return _getErrorMessage(e);
    }
  }

  static Future<SignOutResult> signOut({bool forceLocal = false}) async {
    try {
      if (!forceLocal) {
        await _client.auth.signOut();
        return SignOutResult.success();
      } else {
        await _forceLocalSignOut();
        return SignOutResult.successLocal();
      }
    } catch (e) {
      // En cas d'erreur réseau, forcer la déconnexion locale
      try {
        await _forceLocalSignOut();
        return SignOutResult.errorButLocalSuccess(_getErrorMessage(e));
      } catch (localError) {
        return SignOutResult.error(_getErrorMessage(e));
      }
    }
  }

  static Future<void> _forceLocalSignOut() async {
    // Force la suppression de la session côté client
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  static Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null; // Success
    } catch (e) {
      return _getErrorMessage(e);
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Email ou mot de passe incorrect';
        case 'email not confirmed':
          return 'Veuillez confirmer votre email avant de vous connecter';
        case 'user already registered':
          return 'Un compte existe déjà avec cet email';
        case 'password should be at least 6 characters':
          return 'Le mot de passe doit contenir au moins 6 caractères';
        case 'invalid email':
          return 'Adresse email invalide';
        default:
          return error.message;
      }
    }
    return 'Une erreur inattendue s\'est produite';
  }
}
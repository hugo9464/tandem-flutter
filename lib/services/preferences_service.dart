import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _mainAccountKey = 'main_account_iban';
  static const String _goCardlessRequisitionKey = 'gocardless_requisition';
  static const String _goCardlessInstitutionKey = 'gocardless_institution';
  
  Future<void> setMainAccount(String iban) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mainAccountKey, iban);
  }
  
  Future<String?> getMainAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mainAccountKey);
  }
  
  Future<void> clearMainAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mainAccountKey);
  }
  
  Future<bool> hasMainAccount() async {
    final mainAccount = await getMainAccount();
    return mainAccount != null && mainAccount.isNotEmpty;
  }
  
  // GoCardless connection management
  Future<void> saveGoCardlessConnection({
    required String requisitionId,
    required Map<String, dynamic> institutionData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goCardlessRequisitionKey, requisitionId);
    await prefs.setString(_goCardlessInstitutionKey, jsonEncode(institutionData));
  }
  
  Future<String?> getGoCardlessRequisitionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_goCardlessRequisitionKey);
  }
  
  Future<Map<String, dynamic>?> getGoCardlessInstitution() async {
    final prefs = await SharedPreferences.getInstance();
    final institutionJson = prefs.getString(_goCardlessInstitutionKey);
    if (institutionJson != null) {
      return jsonDecode(institutionJson) as Map<String, dynamic>;
    }
    return null;
  }
  
  Future<bool> hasGoCardlessConnection() async {
    final requisitionId = await getGoCardlessRequisitionId();
    return requisitionId != null && requisitionId.isNotEmpty;
  }
  
  Future<void> clearGoCardlessConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goCardlessRequisitionKey);
    await prefs.remove(_goCardlessInstitutionKey);
  }
}
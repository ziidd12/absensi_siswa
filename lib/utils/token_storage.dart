import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userSerialKey = 'user_serial_number'; 
  static const _userRoleKey = 'user_role';

  static Future<void> saveUserSession({
    required String token,
    required int id,
    String? name,
    required String serialNumber,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, id);
    await prefs.setString(_userNameKey, name ?? "No Name"); // Handle jika name null
    await prefs.setString(_userSerialKey, serialNumber);
    await prefs.setString(_userRoleKey, role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }
  
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserSerialNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userSerialKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppStorage {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _userConfigKey = 'user_config';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users'; // Store all registered users

  // User authentication methods
  static Future<bool> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load existing users
    final users = await getAllUsers();
    
    // Check if username already exists
    if (users.any((u) => u.username.toLowerCase() == user.username.toLowerCase())) {
      return false; // Username already taken
    }
    
    // Add new user
    users.add(user);
    
    // Save all users
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
    
    return true;
  }

  static Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_usersKey);
    if (encoded == null) return [];
    
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((u) => User.fromJson(u)).toList();
  }

  static Future<User?> authenticateUser(String username, String password) async {
    final users = await getAllUsers();
    
    try {
      return users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase() && 
               u.password == password,
      );
    } catch (e) {
      return null; // User not found or password incorrect
    }
  }

  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_currentUserKey);
    if (encoded == null) return null;
    return User.fromJson(jsonDecode(encoded));
  }

  // Assignment methods
  static Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      assignments.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_assignmentsKey, encoded);
  }

  static Future<List<Assignment>> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_assignmentsKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => Assignment.fromJson(e)).toList();
  }

  // Session methods
  static Future<void> saveSessions(List<Session> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }

  static Future<List<Session>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_sessionsKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => Session.fromJson(e)).toList();
  }

  // User config methods (kept for compatibility)
  static Future<void> saveUserConfig(UserConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userConfigKey, jsonEncode(config.toJson()));
  }

  static Future<UserConfig?> loadUserConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_userConfigKey);
    if (encoded == null) return null;
    return UserConfig.fromJson(jsonDecode(encoded));
  }

  // Login state methods
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserKey);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
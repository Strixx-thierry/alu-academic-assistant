import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alu_academic_assistant/models/models.dart';

/// Service responsible for persistent data storage using SharedPreferences.
/// Design Decision: Encapsulating storage logic in a dedicated service
/// decoupled from the UI. This follows the Single Responsibility Principle and makes it easier to swap the storage implementation (e.g., to SQLite or Hive) without affecting the screens.
class AppStorage {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users';

  // --- Authentication Management ---

  /// Registers a new user if the username is unique.
  static Future<bool> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();

    if (users.any(
      (u) => u.username.toLowerCase() == user.username.toLowerCase(),
    )) {
      return false;
    }

    users.add(user);
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);

    return true;
  }

  /// Retrieves all registered users from local storage.
  static Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_usersKey);
    if (encoded == null) return [];

    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((u) => User.fromJson(u)).toList();
  }

  /// Authenticates credentials against stored users.
  static Future<User?> authenticateUser(
    String username,
    String password,
  ) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere(
        (u) =>
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Persists the currently logged-in user session.
  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Retrieves the current active user session.
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_currentUserKey);
    if (encoded == null) return null;
    return User.fromJson(jsonDecode(encoded));
  }

  // --- Data Management (Assignments & Sessions) ---

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

  // --- Session State Management ---

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

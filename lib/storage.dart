import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';


class AppStorage {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';


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


  static const String _userConfigKey = 'user_config';


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
}




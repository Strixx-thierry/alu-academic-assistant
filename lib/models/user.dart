import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// User model representing a student profile and credentials.
/// Design Decision: Using a dedicated User model with JSON serialization
/// allows for easy persistence using the StorageService.
class User {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final String year;
  final String trimester;

  User({
    String? id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.year,
    required this.trimester,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'year': year,
      'trimester': trimester,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      fullName: json['fullName'],
      year: json['year'],
      trimester: json['trimester'],
    );
  }
}

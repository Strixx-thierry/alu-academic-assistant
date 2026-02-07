import 'package:uuid/uuid.dart';

const uuid = Uuid();

// User model with authentication credentials
class User {
  final String id;
  final String username;
  final String password; // In production, this should be hashed
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
  }) : id = id ?? uuid.v4();

  // Convert to JSON for storage
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

  // Create from JSON
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

// User configuration model (kept for compatibility)
class UserConfig {
  final String studentName;
  final String year;
  final String trimester;

  UserConfig({
    required this.studentName,
    required this.year,
    required this.trimester,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'year': year,
      'trimester': trimester,
    };
  }

  // Create from JSON
  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      studentName: json['studentName'] ?? '',
      year: json['year'] ?? 'Year 1',
      trimester: json['trimester'] ?? 'Trimester 1',
    );
  }
}

// Assignment model
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final String priority; // High, Medium, Low
  bool isCompleted;

  Assignment({
    String? id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority = 'Medium',
    this.isCompleted = false,
  }) : id = id ?? uuid.v4();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      dueDate: DateTime.parse(json['dueDate']),
      courseName: json['courseName'],
      priority: json['priority'] ?? 'Medium',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Create a copy with modified fields
  Assignment copyWith({
    String? title,
    DateTime? dueDate,
    String? courseName,
    String? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Session model for academic sessions
class Session {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String type; // Lecture, Practical, Workshop, etc.
  bool isAttended;

  Session({
    String? id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.type = 'Lecture',
    this.isAttended = false,
  }) : id = id ?? uuid.v4();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type,
      'isAttended': isAttended,
    };
  }

  // Create from JSON
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'] ?? '',
      type: json['type'] ?? 'Lecture',
      isAttended: json['isAttended'] ?? false,
    );
  }

  // Create a copy with modified fields
  Session copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? type,
    bool? isAttended,
  }) {
    return Session(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      isAttended: isAttended ?? this.isAttended,
    );
  }
}
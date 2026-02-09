import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Session model for academic classes and meetings.
///
/// Design Decision: Tracking attendance through a boolean flag
/// allows for automated calculation of attendance percentages
/// on the dashboard.
class Session {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String type; // Lecture, Practical, Workshop, etc.
  final bool isAttended;

  Session({
    String? id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.type = 'Lecture',
    this.isAttended = false,
  }) : id = id ?? _uuid.v4();

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

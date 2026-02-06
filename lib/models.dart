class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final String course;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.course,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
    'course': course,
  };

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
    id: json['id'],
    title: json['title'],
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'],
    course: json['course'],
  );

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    String? course,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      course: course ?? this.course,
    );
  }
}

class Session {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String type;
  final bool isAttended;

  Session({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    this.isAttended = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'location': location,
    'type': type,
    'isAttended': isAttended,
  };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'],
    title: json['title'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    location: json['location'],
    type: json['type'],
    isAttended: json['isAttended'] ?? false,
  );

  Session copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? type,
    bool? isAttended,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      isAttended: isAttended ?? this.isAttended,
    );
  }
}

class UserConfig {
  final String studentName;
  final String year;
  final String trimester;

  UserConfig({
    required this.studentName,
    required this.year,
    required this.trimester,
  });

  Map<String, dynamic> toJson() => {
    'studentName': studentName,
    'year': year,
    'trimester': trimester,
  };

  factory UserConfig.fromJson(Map<String, dynamic> json) => UserConfig(
    studentName: json['studentName'],
    year: json['year'],
    trimester: json['trimester'],
  );
}

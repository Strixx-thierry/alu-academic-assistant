class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class Session {
  final String id;
  final String subject;
  final DateTime startTime;
  final String location;

  Session({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.location,
  });
}

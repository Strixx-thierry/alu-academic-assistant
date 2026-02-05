import 'package:flutter/material.dart';
import 'models.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  /// List of sessions (temporary in-memory data)
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();

    // Load temporary sample data
    _loadSampleData();
  }

  /// Creates sample sessions for UI testing
  /// Will be replaced with storage loading later
  void _loadSampleData() {
    _sessions = [
      Session(
        title: "Math Class",
        date: DateTime.now(),
        startTime: "10:00",
        endTime: "12:00",
        location: "Room A",
        type: "Class",
        isPresent: true,
      ),

      Session(
        title: "Study Group",
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: "14:00",
        endTime: "15:00",
        location: "Library",
        type: "Study Group",
        isPresent: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),

      body: Center(
        child: Text(
          "Loaded Sessions: ${_sessions.length}",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'models.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),

      body: _sessions.isEmpty
          ? const Center(
              child: Text(
                "No sessions available",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _sessions.length,

              itemBuilder: (context, index) {

                final session = _sessions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(

                    title: Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const SizedBox(height: 4),

                        Text(
                          "Date: ${_formatDate(session.date)}",
                        ),

                        Text(
                          "Time: ${session.startTime} - ${session.endTime}",
                        ),

                        if (session.location != null &&
                            session.location!.isNotEmpty)

                          Text(
                            "Location: ${session.location}",
                          ),

                        Text(
                          "Type: ${session.type}",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

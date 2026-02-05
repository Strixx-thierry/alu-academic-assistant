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

  void _toggleAttendance(int index, bool value) {
    setState(() {
      _sessions[index].isPresent = value;
    });

    // TODO: Save updated attendance to storage
  }

  double _calculateAttendancePercentage() {
    if (_sessions.isEmpty) return 0;

    int presentCount =
        _sessions.where((s) => s.isPresent).length;

    return (presentCount / _sessions.length) * 100;
  }

  @override
  Widget build(BuildContext context) {

    final double attendancePercent =
        _calculateAttendancePercentage();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),

      body: Column(
        children: [

          // ================= Attendance Summary =================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),

            color: Colors.blue.shade50,

            child: Column(
              children: [

                Text(
                  "Attendance: ${attendancePercent.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Present: ${_sessions.where((s) => s.isPresent).length} / ${_sessions.length}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          // ================= Session List =================

          Expanded(
            child: _sessions.isEmpty
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

                          trailing: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Switch(
                                value: session.isPresent,

                                onChanged: (value) {
                                  _toggleAttendance(index, value);
                                },
                              ),

                              Text(
                                session.isPresent
                                    ? "Present"
                                    : "Absent",

                                style: TextStyle(
                                  fontSize: 12,

                                  color: session.isPresent
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }
}

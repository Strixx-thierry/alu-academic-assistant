import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  List<Session> _sessions = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // ================= Storage Integration =================

  Future<void> _loadSessions() async {
    try {
      final data = await AppStorage.loadSessions();

      if (data.isNotEmpty) {
        _sessions = data;
      } else {
        _loadSampleData();
      }

    } catch (e) {
      _loadSampleData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSessions() async {
    try {
      await AppStorage.saveSessions(_sessions);
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  // ================= Sample Data =================

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

  // ================= Helpers =================

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _toggleAttendance(int index, bool value) {
    setState(() {
      _sessions[index].isPresent = value;
    });

    _saveSessions();
  }

  double _calculateAttendancePercentage() {
    if (_sessions.isEmpty) return 0;

    int presentCount =
        _sessions.where((s) => s.isPresent).length;

    return (presentCount / _sessions.length) * 100;
  }

  bool _isLowAttendance(double percent) {
    return percent < 75;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    final double attendancePercent =
        _calculateAttendancePercentage();

    final bool isLow =
        _isLowAttendance(attendancePercent);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [

                // ========== Summary ==========

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  color: isLow
                      ? Colors.red.shade100
                      : Colors.green.shade100,

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
                      ),

                      if (isLow) ...[
                        const SizedBox(height: 6),

                        const Text(
                          "⚠️ Warning: Attendance below 75%",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ========== List ==========

                Expanded(
                  child: _sessions.isEmpty
                      ? const Center(
                          child: Text("No sessions available"),
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
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'models.dart';
import 'storage.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});


  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  List<Session> _todaySessions = [];
  List<Assignment> _upcomingAssignments = [];
  double _attendancePercentage = 0.0;


  UserConfig? _userConfig;


  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }


  Future<void> _loadDashboardData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);


    final sessions = await AppStorage.loadSessions();
    final assignments = await AppStorage.loadAssignments();
    final config = await AppStorage.loadUserConfig();


    setState(() {
      _userConfig = config;
      _todaySessions = sessions.where((s) {
        final sDate = DateTime(
          s.startTime.year,
          s.startTime.month,
          s.startTime.day,
        );
        return sDate.isAtSameMomentAs(today);
      }).toList();


      _upcomingAssignments = assignments.where((a) {
        return !a.isCompleted &&
            a.dueDate.isAfter(now) &&
            a.dueDate.isBefore(now.add(const Duration(days: 7)));
      }).toList();


      final pastSessions = sessions
          .where((s) => s.startTime.isBefore(now))
          .toList();
      if (pastSessions.isNotEmpty) {
        final attended = pastSessions.where((s) => s.isAttended).length;
        _attendancePercentage = (attended / pastSessions.length) * 100;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userConfig != null
              ? "Hello, ${_userConfig!.studentName}"
              : 'Academic Assistant',
        ),
        backgroundColor: AluColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttendanceCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Today\'s Sessions'),
            _buildSessionList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Upcoming Assignments'),
            _buildAssignmentList(),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AluColors.primaryBlue,
        ),
      ),
    );
  }


  Widget _buildAttendanceCard() {
    final isWarning = _attendancePercentage < 75 && _attendancePercentage > 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularProgressIndicator(
              value: _attendancePercentage / 100,
              backgroundColor: Colors.grey[200],
              color: isWarning ? Colors.red : Colors.green,
              strokeWidth: 8,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_attendancePercentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text("Overall Attendance"),
                if (isWarning)
                  const Text(
                    "⚠️ Below 75% goal!",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSessionList() {
    if (_todaySessions.isEmpty) {
      return const Card(child: ListTile(title: Text("No sessions today")));
    }
    return Column(
      children: _todaySessions
          .map(
            (s) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: AluColors.primaryBlue,
                ),
                title: Text(s.title),
                subtitle: Text(DateFormat('hh:mm a').format(s.startTime)),
              ),
            ),
          )
          .toList(),
    );
  }


  Widget _buildAssignmentList() {
    if (_upcomingAssignments.isEmpty) {
      return const Card(
        child: ListTile(title: Text("No upcoming assignments")),
      );
    }
    return Column(
      children: _upcomingAssignments
          .map(
            (a) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.assignment_late,
                  color: AluColors.primaryRed,
                ),
                title: Text(a.title),
                subtitle: Text("Due: ${DateFormat('MMM d').format(a.dueDate)}"),
              ),
            ),
          )
          .toList(),
    );
  }
}





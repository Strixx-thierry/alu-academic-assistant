import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';
import 'package:alu_academic_assistant/models/models.dart';
import 'package:alu_academic_assistant/services/storage_service.dart';
import 'package:alu_academic_assistant/widgets/section_header.dart';
import 'package:alu_academic_assistant/widgets/stat_card.dart';

/// The central hub of the application providing a summary of student's status.
///
/// Design Decision: A mix of visual data (attendance circle), quick metrics
/// (stat cards), and chronological lists (today's sessions) provides a
/// comprehensive yet accessible overview for the student.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Session> _todaySessions = [];
  List<Assignment> _upcomingAssignments = [];
  double _attendancePercentage = 0.0;
  int _totalPastSessions = 0;
  int _attendedSessions = 0;
  int _pendingAssignments = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Fetches and processes data from local storage for the dashboard view.
  Future<void> _loadDashboardData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sessions = await AppStorage.loadSessions();
    final assignments = await AppStorage.loadAssignments();
    final user = await AppStorage.getCurrentUser();

    setState(() {
      _currentUser = user;

      // Filter sessions for today only
      _todaySessions = sessions.where((s) {
        final sDate = DateTime(
          s.startTime.year,
          s.startTime.month,
          s.startTime.day,
        );
        return sDate.isAtSameMomentAs(today);
      }).toList();

      // Filter incomplete assignments due in the next week
      _upcomingAssignments = assignments.where((a) {
        return !a.isCompleted &&
            a.dueDate.isAfter(now) &&
            a.dueDate.isBefore(now.add(const Duration(days: 7)));
      }).toList();

      _pendingAssignments = assignments.where((a) => !a.isCompleted).length;

      // Calculate attendance based on past events
      final pastSessions = sessions
          .where((s) => s.startTime.isBefore(now))
          .toList();
      _totalPastSessions = pastSessions.length;

      if (pastSessions.isNotEmpty) {
        _attendedSessions = pastSessions.where((s) => s.isAttended).length;
        _attendancePercentage = (_attendedSessions / pastSessions.length) * 100;
      } else {
        _attendedSessions = 0;
        _attendancePercentage = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekNumber = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7)
        .ceil();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(now, weekNumber),
              const SizedBox(height: 24),
              _buildAttendanceCard(),
              const SizedBox(height: 16),
              _buildQuickStatsRow(),
              const SizedBox(height: 24),
              const SectionHeader(
                title: "Today's Sessions",
                showIndicator: false,
              ),
              _buildSessionList(),
              const SizedBox(height: 24),
              const SectionHeader(
                title: "Upcoming Assignments (7 Days)",
                showIndicator: false,
              ),
              _buildAssignmentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now, int weekNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentUser != null
              ? "Hello, ${_currentUser!.fullName.split(' ').first}! 👋"
              : 'Academic Assistant',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AluColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(now),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Academic Week $weekNumber',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    final isWarning = _attendancePercentage < 75 && _totalPastSessions > 0;
    final isGood = _attendancePercentage >= 75;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isWarning
          ? Colors.red[50]
          : (isGood ? Colors.green[50] : Colors.grey[50]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: CircularProgressIndicator(
                      value: _totalPastSessions > 0
                          ? _attendancePercentage / 100
                          : 0,
                      backgroundColor: Colors.grey[300],
                      color: isWarning
                          ? Colors.red
                          : (isGood ? Colors.green : Colors.grey),
                      strokeWidth: 10,
                    ),
                  ),
                  Text(
                    _totalPastSessions > 0
                        ? "${_attendancePercentage.toStringAsFixed(0)}%"
                        : "N/A",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isWarning
                          ? Colors.red
                          : (isGood ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Attendance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_attendedSessions / $_totalPastSessions sessions",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  if (isWarning)
                    _buildStatusBadge(
                      "Below 75% Target!",
                      Colors.red,
                      Icons.warning,
                    ),
                  if (isGood)
                    _buildStatusBadge(
                      "Great Job!",
                      Colors.green,
                      Icons.check_circle,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Today',
            value: _todaySessions.length.toString(),
            subtitle: 'Sessions',
            icon: Icons.event,
            color: AluColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Pending',
            value: _pendingAssignments.toString(),
            subtitle: 'Assignments',
            icon: Icons.assignment_late,
            color: AluColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionList() {
    if (_todaySessions.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text("No sessions scheduled for today"),
        ),
      );
    }
    return Column(
      children: _todaySessions
          .map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AluColors.primaryBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.school,
                    color: AluColors.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  s.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  "${DateFormat('hh:mm a').format(s.startTime)} - ${s.type}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: s.location.isNotEmpty
                    ? Text(
                        s.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAssignmentList() {
    if (_upcomingAssignments.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue),
          title: Text("Clear schedule for the next 7 days"),
        ),
      );
    }
    return Column(
      children: _upcomingAssignments
          .map(
            (a) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AluColors.primaryRed.withOpacity(0.1),
                  child: const Icon(
                    Icons.assignment,
                    color: AluColors.primaryRed,
                    size: 20,
                  ),
                ),
                title: Text(
                  a.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  "Due: ${DateFormat('MMM d').format(a.dueDate)} • ${a.courseName}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: a.priority == 'High'
                        ? Colors.red[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: a.priority == 'High'
                          ? Colors.red
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

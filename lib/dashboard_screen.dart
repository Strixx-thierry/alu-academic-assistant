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
  int _totalPastSessions = 0;
  int _attendedSessions = 0;
  int _pendingAssignments = 0;

  User? _currentUser;

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
    final user = await AppStorage.getCurrentUser();

    setState(() {
      _currentUser = user;
      
      // Today's sessions
      _todaySessions = sessions.where((s) {
        final sDate = DateTime(
          s.startTime.year,
          s.startTime.month,
          s.startTime.day,
        );
        return sDate.isAtSameMomentAs(today);
      }).toList();

      // Upcoming assignments (next 7 days)
      _upcomingAssignments = assignments.where((a) {
        return !a.isCompleted &&
            a.dueDate.isAfter(now) &&
            a.dueDate.isBefore(now.add(const Duration(days: 7)));
      }).toList();

      // Pending assignments count
      _pendingAssignments = assignments.where((a) => !a.isCompleted).length;

      // Attendance calculation (only count past sessions)
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
    final weekNumber = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and week
              _buildHeader(now, weekNumber),
              const SizedBox(height: 24),
              
              // Attendance Card
              _buildAttendanceCard(),
              const SizedBox(height: 16),

              // Quick Stats Row
              _buildQuickStatsRow(),
              const SizedBox(height: 24),

              // Today's Sessions
              _buildSectionTitle('Today\'s Sessions'),
              _buildSessionList(),
              const SizedBox(height: 24),

              // Upcoming Assignments
              _buildSectionTitle('Upcoming Assignments (Next 7 Days)'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AluColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final isWarning = _attendancePercentage < 75 && _totalPastSessions > 0;
    final isGood = _attendancePercentage >= 75;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isWarning ? Colors.red[50] : (isGood ? Colors.green[50] : Colors.grey[50]),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                // Circular Progress Indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _totalPastSessions > 0 ? _attendancePercentage / 100 : 0,
                        backgroundColor: Colors.grey[300],
                        color: isWarning
                            ? Colors.red
                            : (isGood ? Colors.green : Colors.grey),
                        strokeWidth: 8,
                      ),
                      Text(
                        _totalPastSessions > 0
                            ? "${_attendancePercentage.toStringAsFixed(0)}%"
                            : "N/A",
                        style: TextStyle(
                          fontSize: 20,
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
                // Attendance Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Overall Attendance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$_attendedSessions / $_totalPastSessions sessions attended",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      if (isWarning) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Below 75% Target!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isGood) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Great Job!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today',
            _todaySessions.length.toString(),
            'Sessions',
            Icons.event,
            AluColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            _pendingAssignments.toString(),
            'Assignments',
            Icons.assignment,
            AluColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    if (_todaySessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[300]),
              const SizedBox(width: 12),
              const Text("No sessions scheduled for today"),
            ],
          ),
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
                  ),
                ),
                title: Text(
                  s.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.type),
                    Text(
                      "${DateFormat('hh:mm a').format(s.startTime)} - ${DateFormat('hh:mm a').format(s.endTime)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: s.location.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          Text(
                            s.location,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[300]),
              const SizedBox(width: 12),
              const Text("No assignments due in the next 7 days"),
            ],
          ),
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
                  ),
                ),
                title: Text(
                  a.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.courseName),
                    Text(
                      "Due: ${DateFormat('MMM d, yyyy').format(a.dueDate)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: a.priority.isNotEmpty
                    ? Chip(
                        label: Text(
                          a.priority,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: a.priority == 'High'
                            ? Colors.red[100]
                            : (a.priority == 'Medium'
                                ? Colors.orange[100]
                                : Colors.green[100]),
                      )
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
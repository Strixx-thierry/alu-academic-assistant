import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';
import 'package:alu_academic_assistant/models/models.dart';
import 'package:alu_academic_assistant/services/storage_service.dart';
import 'package:alu_academic_assistant/widgets/section_header.dart';

/// Module for tracking academic sessions and attendance.
///
/// Design Decision: Splitting sessions into Upcoming and Past categories
/// allows students to look ahead at their schedule while easily
/// marking attendance for events that have already occurred.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Session> _sessions = [];
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await AppStorage.loadSessions();
    setState(() {
      _sessions = data;
      _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  Future<void> _saveData() async {
    await AppStorage.saveSessions(_sessions);
  }

  /// Opens a dialog to create or update an academic session.
  void _addOrEditSession([Session? session]) {
    final isEditing = session != null;
    final titleController = TextEditingController(text: session?.title ?? '');
    final locationController = TextEditingController(
      text: session?.location ?? '',
    );
    DateTime selectedDate = session?.startTime ?? DateTime.now();
    TimeOfDay startTime = session != null
        ? TimeOfDay.fromDateTime(session.startTime)
        : TimeOfDay.now();
    TimeOfDay endTime = session != null
        ? TimeOfDay.fromDateTime(session.endTime)
        : TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0);
    String selectedType = session?.type ?? 'Lecture';

    const sessionTypes = [
      'Class',
      'Mastery Session',
      'Study Group',
      'Lecture',
      'Workshop',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(isEditing ? 'Edit Session' : 'New Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: sessionTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Date: ${_dateFormat.format(selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 90),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null)
                      setDialogState(() => selectedDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Start: ${startTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null)
                      setDialogState(() => startTime = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("End: ${endTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) setDialogState(() => endTime = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;

                final start = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );
                final end = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                final newSession = Session(
                  id: isEditing ? session.id : null,
                  title: titleController.text.trim(),
                  startTime: start,
                  endTime: end,
                  location: locationController.text.trim(),
                  type: selectedType,
                  isAttended: isEditing ? session.isAttended : false,
                );

                setState(() {
                  if (isEditing) {
                    final idx = _sessions.indexWhere((s) => s.id == session.id);
                    _sessions[idx] = newSession;
                  } else {
                    _sessions.add(newSession);
                  }
                  _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
                });
                _saveData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AluColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSession(String id) {
    setState(() => _sessions.removeWhere((s) => s.id == id));
    _saveData();
  }

  void _toggleAttendance(Session session) {
    setState(() {
      final idx = _sessions.indexWhere((s) => s.id == session.id);
      _sessions[idx] = session.copyWith(isAttended: !session.isAttended);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = _sessions.where((s) => s.startTime.isAfter(now)).toList();
    final past = _sessions.where((s) => s.startTime.isBefore(now)).toList();

    return Scaffold(
      body: _sessions.isEmpty
          ? const Center(
              child: Text(
                'No academic schedule found.\nTap + to add your first session.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const SectionHeader(title: 'Upcoming Sessions'),
                  ...upcoming.map((s) => _buildSessionCard(s, false)),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  const SectionHeader(
                    title: 'Attendance Log',
                    color: Colors.grey,
                  ),
                  ...past.map((s) => _buildSessionCard(s, true)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSession(),
        backgroundColor: AluColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSessionCard(Session session, bool isPast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.type,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPast
                        ? (session.isAttended ? Colors.green : Colors.red)
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPast
                        ? (session.isAttended ? 'Present' : 'Absent')
                        : 'Upcoming',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _dateFormat.format(session.startTime),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "${_timeFormat.format(session.startTime)} - ${_timeFormat.format(session.endTime)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            if (isPast) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _toggleAttendance(session),
                    icon: Icon(
                      session.isAttended ? Icons.cancel : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(
                      session.isAttended ? 'Mark Absent' : 'Mark Present',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: session.isAttended
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _deleteSession(session.id),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

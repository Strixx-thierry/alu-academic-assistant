import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'models.dart';
import 'storage.dart';

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

  void _addOrEditSession([Session? session]) {
    final isEditing = session != null;
    final titleController = TextEditingController(
      text: session?.title ?? '',
    );
    final locationController = TextEditingController(
      text: session?.location ?? '',
    );
    DateTime selectedDate = session?.startTime ?? DateTime.now();
    TimeOfDay startTime = session != null
        ? TimeOfDay.fromDateTime(session.startTime)
        : TimeOfDay.now();
    TimeOfDay endTime = session != null
        ? TimeOfDay.fromDateTime(session.endTime)
        : TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
    String selectedType = session?.type ?? 'Lecture';

    final sessionTypes = [
      'Class',
      'Mastery Session',
      'Study Group',
      'PSL Meeting',
      'Lecture',
      'Practical',
      'Workshop'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Session' : 'Add Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Session Title *',
                    hintText: 'e.g., Software Development',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    hintText: 'e.g., Room 202',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Session Type',
                  ),
                  items: sessionTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedType = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Date: ${_dateFormat.format(selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Start Time: ${startTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setDialogState(() => startTime = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("End Time: ${endTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setDialogState(() => endTime = picked);
                    }
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
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final startDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  endTime.hour,
                  endTime.minute,
                );

                final newSession = Session(
                  id: isEditing ? session.id : null,
                  title: titleController.text,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  location: locationController.text,
                  type: selectedType,
                  isAttended: isEditing ? session.isAttended : false,
                );

                setState(() {
                  if (isEditing) {
                    final index = _sessions.indexWhere(
                      (s) => s.id == session.id,
                    );
                    _sessions[index] = newSession;
                  } else {
                    _sessions.add(newSession);
                  }
                  _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
                });
                _saveData();
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSession(String id) {
    setState(() {
      _sessions.removeWhere((s) => s.id == id);
    });
    _saveData();
  }

  void _toggleAttendance(Session session) {
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      _sessions[index] = session.copyWith(
        isAttended: !session.isAttended,
      );
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    // Group sessions by week
    final now = DateTime.now();
    final upcomingSessions = _sessions
        .where((s) => s.startTime.isAfter(now))
        .toList();
    final pastSessions = _sessions
        .where((s) => s.startTime.isBefore(now))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: AluColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _sessions.isEmpty
          ? const Center(
              child: Text(
                'No sessions scheduled yet.\nTap + to add a session.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (upcomingSessions.isNotEmpty) ...[
                  _buildSectionHeader('Upcoming Sessions'),
                  ...upcomingSessions.map((s) => _buildSessionCard(s, false)),
                  const SizedBox(height: 24),
                ],
                if (pastSessions.isNotEmpty) ...[
                  _buildSectionHeader('Past Sessions'),
                  ...pastSessions.map((s) => _buildSessionCard(s, true)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
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

  Widget _buildSessionCard(Session session, bool isPast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPast
                        ? (session.isAttended ? Colors.green : Colors.red)
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPast
                        ? (session.isAttended ? 'Present' : 'Absent')
                        : 'Upcoming',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _dateFormat.format(session.startTime),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "${_timeFormat.format(session.startTime)} - ${_timeFormat.format(session.endTime)}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            if (session.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.location,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPast)
                  TextButton.icon(
                    onPressed: () => _toggleAttendance(session),
                    icon: Icon(
                      session.isAttended
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 18,
                    ),
                    label: Text(
                      session.isAttended
                          ? 'Mark Absent'
                          : 'Mark Present',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: session.isAttended
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                  onPressed: () => _addOrEditSession(session),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Session?'),
                        content: const Text(
                          'Are you sure you want to delete this session?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteSession(session.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
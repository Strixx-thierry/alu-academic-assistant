import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'colors.dart';
import 'storage.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Session> _sessions = [];
  final DateFormat _dateFormat = DateFormat('EEE, MMM d');
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
    final titleController = TextEditingController(text: session?.title ?? '');
    final locationController = TextEditingController(
      text: session?.location ?? '',
    );
    DateTime selectedDate = session?.startTime ?? DateTime.now();
    TimeOfDay startTime = TimeOfDay.fromDateTime(
      session?.startTime ?? DateTime.now(),
    );
    TimeOfDay endTime = TimeOfDay.fromDateTime(
      session?.endTime ?? DateTime.now().add(const Duration(hours: 1)),
    );
    String selectedType = session?.type ?? 'Lecture';

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
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  items: ['Lecture', 'Lab', 'Study Group', 'Office Hours']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                ListTile(
                  title: Text(_dateFormat.format(selectedDate)),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (p != null) {
                      setDialogState(() => selectedDate = p);
                    }
                  },
                ),
                ListTile(
                  title: Text("Start: ${startTime.format(context)}"),
                  onTap: () async {
                    final p = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (p != null) {
                      setDialogState(() => startTime = p);
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
                final s = Session(
                  id: isEditing ? session.id : DateTime.now().toString(),
                  title: titleController.text,
                  startTime: start,
                  endTime: end,
                  location: locationController.text,
                  type: selectedType,
                  isAttended: isEditing ? session.isAttended : false,
                );
                setState(() {
                  if (isEditing) {
                    final i = _sessions.indexWhere((x) => x.id == session.id);
                    _sessions[i] = s;
                  } else {
                    _sessions.add(s);
                  }
                  _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
                });
                _saveData();
                Navigator.pop(context);
              },
              child: const Text('Save'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: AluColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _sessions.isEmpty
          ? const Center(child: Text('No sessions yet.'))
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final s = _sessions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      s.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${_dateFormat.format(s.startTime)} | ${_timeFormat.format(s.startTime)}\n${s.location} (${s.type})",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSession(s.id),
                    ),
                    onTap: () => _addOrEditSession(s),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditSession(),
        backgroundColor: AluColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO: import 'models.dart'; import 'colors.dart';

class Assignment {
  final String id;
  String title, course;
  DateTime dueDate;
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    this.isCompleted = false,
  });

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
}

class ALUColors {
  static const primary = Color(0xFF1E3A8A);
  static const secondary = Color(0xFFF59E0B);
  static const accent = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
}

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);
  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  List<Assignment> _assignments = [];
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }
  void _loadAssignments() {
    // TODO: Load from storage.dart
    setState(() {
      _assignments = [
        Assignment(
          id: '1',
          title: 'Data Structures Project',
          course: 'CS 201',
          dueDate: DateTime.now().add(Duration(days: 3)),
        ),
        Assignment(
          id: '2',
          title: 'Economics Essay',
          course: 'ECON 101',
          dueDate: DateTime.now().add(Duration(days: 7)),
        ),
      ];
    });
  }

  List<Assignment> get _filtered => (_showCompleted
          ? _assignments
          : _assignments.where((a) => !a.isCompleted).toList())
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  void _showDialog([Assignment? a]) {
    final edit = a != null;
    final title = TextEditingController(text: a?.title);
    final course = TextEditingController(text: a?.course);
    DateTime date = a?.dueDate ?? DateTime.now().add(Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(edit ? 'Edit' : 'New Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: course,
                decoration: InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (d != null) setD(() => date = d);
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Due', border: OutlineInputBorder()),
                  child: Text(DateFormat('MMM dd, yyyy').format(date)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (title.text.isEmpty || course.text.isEmpty) return;
                setState(() {
                  if (edit) {
                    a.title = title.text;
                    a.course = course.text;
                    a.dueDate = date;
                  } else {
                    _assignments.add(Assignment(
                      id: DateTime.now().toString(),
                      title: title.text,
                      course: course.text,
                      dueDate: date,
                    ));
                  }
                });
                Navigator.pop(ctx);
                // TODO: Save to storage
              },
              child: Text(edit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _assignments.removeWhere((a) => a.id == id));
              Navigator.pop(ctx);
              // TODO: Delete from storage
            },
            style: ElevatedButton.styleFrom(backgroundColor: ALUColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pending = _assignments.where((a) => !a.isCompleted).length;
    final overdue = _assignments.where((a) => a.isOverdue).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
        backgroundColor: ALUColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showCompleted = !_showCompleted),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: ALUColors.primary,
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Pending', pending, ALUColors.secondary),
                _stat('Overdue', overdue, ALUColors.error),
                _stat('Total', _assignments.length, ALUColors.accent),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No assignments', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _card(filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        backgroundColor: ALUColors.secondary,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _stat(String label, int val, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(val.toString(),
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card(Assignment a) {
    final color = a.isCompleted ? ALUColors.accent : (a.isOverdue ? ALUColors.error : ALUColors.primary);
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: a.isCompleted,
          onChanged: (_) => setState(() => a.isCompleted = !a.isCompleted),
          activeColor: ALUColors.accent,
        ),
        title: Text(a.title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: a.isCompleted ? TextDecoration.lineThrough : null)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(a.course, style: TextStyle(color: ALUColors.primary)),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: color),
                SizedBox(width: 4),
                Text(DateFormat('MMM dd').format(a.dueDate),
                    style: TextStyle(color: color, fontSize: 12)),
                if (a.isOverdue && !a.isCompleted) ...[
                  SizedBox(width: 8),
                  Text('OVERDUE',
                      style: TextStyle(
                          color: ALUColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              child: Text('Edit'),
              onTap: () => Future.delayed(Duration.zero, () => _showDialog(a)),
            ),
            PopupMenuItem(
              child: Text('Delete', style: TextStyle(color: ALUColors.error)),
              onTap: () => Future.delayed(Duration.zero, () => _delete(a.id)),
            ),
          ],
        ),
      ),
    );
  }
}
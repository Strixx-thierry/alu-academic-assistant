import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'colors.dart';
import 'storage.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  List<Assignment> _assignments = [];
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await AppStorage.loadAssignments();
    setState(() {
      _assignments = data;
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
  }

  Future<void> _saveData() async {
    await AppStorage.saveAssignments(_assignments);
  }

  void _addOrEditAssignment([Assignment? assignment]) {
    final isEditing = assignment != null;
    final titleController = TextEditingController(
      text: assignment?.title ?? '',
    );
    final courseController = TextEditingController(
      text: assignment?.courseName ?? '', // Changed from .course to .courseName
    );
    DateTime selectedDate = assignment?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Assignment' : 'Add Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course'),
              ),
              ListTile(
                title: Text("Due Date: ${_dateFormat.format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  return;
                }
                final newAssignment = Assignment(
                  id: isEditing ? assignment.id : null, // Let the model generate ID
                  title: titleController.text,
                  courseName: courseController.text, // Changed from course to courseName
                  dueDate: selectedDate,
                  isCompleted: isEditing ? assignment.isCompleted : false,
                );

                setState(() {
                  if (isEditing) {
                    final index = _assignments.indexWhere(
                      (a) => a.id == assignment.id,
                    );
                    _assignments[index] = newAssignment;
                  } else {
                    _assignments.add(newAssignment);
                  }
                  _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
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

  void _deleteAssignment(String id) {
    setState(() {
      _assignments.removeWhere((a) => a.id == id);
    });
    _saveData();
  }

  void _toggleComplete(Assignment assignment) {
    setState(() {
      final index = _assignments.indexWhere((a) => a.id == assignment.id);
      _assignments[index] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: AluColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _assignments.isEmpty
          ? const Center(child: Text('No assignments yet.'))
          : ListView.builder(
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final item = _assignments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.isCompleted,
                      onChanged: (_) => _toggleComplete(item),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${item.courseName} | Due: ${_dateFormat.format(item.dueDate)}", // Changed from .course to .courseName
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditAssignment(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAssignment(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAssignment(),
        backgroundColor: AluColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
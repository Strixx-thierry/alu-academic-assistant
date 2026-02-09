import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alu_academic_assistant/models/models.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';
import 'package:alu_academic_assistant/services/storage_service.dart';
import 'package:alu_academic_assistant/widgets/section_header.dart';

/// Module for managing academic assignments and tasks.
///
/// Design Decision: Categorizing assignments into Overdue, Pending, and
/// Completed provides a natural workflow for students to prioritize
/// their academic work.
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

  /// Opens a dialog to create or update an assignment.
  void _addOrEditAssignment([Assignment? assignment]) {
    final isEditing = assignment != null;
    final titleController = TextEditingController(
      text: assignment?.title ?? '',
    );
    final courseController = TextEditingController(
      text: assignment?.courseName ?? '',
    );
    DateTime selectedDate = assignment?.dueDate ?? DateTime.now();
    String selectedPriority = assignment?.priority ?? 'Medium';

    const priorities = ['High', 'Medium', 'Low'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'e.g., Final Paper',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g., Computer Science',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority Level',
                  ),
                  items: priorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setDialogState(() => selectedPriority = val);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Due Date: ${_dateFormat.format(selectedDate)}"),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null)
                      setDialogState(() => selectedDate = picked);
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
                if (titleController.text.isEmpty ||
                    courseController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Required fields missing')),
                  );
                  return;
                }

                final newAssignment = Assignment(
                  id: isEditing ? assignment.id : null,
                  title: titleController.text.trim(),
                  courseName: courseController.text.trim(),
                  dueDate: selectedDate,
                  priority: selectedPriority,
                  isCompleted: isEditing ? assignment.isCompleted : false,
                );

                setState(() {
                  if (isEditing) {
                    final idx = _assignments.indexWhere(
                      (a) => a.id == assignment.id,
                    );
                    _assignments[idx] = newAssignment;
                  } else {
                    _assignments.add(newAssignment);
                  }
                  _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
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

  void _deleteAssignment(String id) {
    setState(() => _assignments.removeWhere((a) => a.id == id));
    _saveData();
  }

  void _toggleComplete(Assignment assignment) {
    setState(() {
      final idx = _assignments.indexWhere((a) => a.id == assignment.id);
      _assignments[idx] = assignment.copyWith(
        isCompleted: !assignment.isCompleted,
      );
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completed = _assignments.where((a) => a.isCompleted).toList();
    final overdue = _assignments
        .where((a) => !a.isCompleted && a.dueDate.isBefore(today))
        .toList();
    final pending = _assignments
        .where((a) => !a.isCompleted && !a.dueDate.isBefore(today))
        .toList();

    return Scaffold(
      body: _assignments.isEmpty
          ? const Center(
              child: Text(
                'No assignments found. Tap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (overdue.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'Overdue Tasks',
                      color: Colors.red,
                    ),
                    ...overdue.map((a) => _buildAssignmentCard(a, true)),
                    const SizedBox(height: 24),
                  ],
                  if (pending.isNotEmpty) ...[
                    const SectionHeader(title: 'Pending Tasks'),
                    ...pending.map((a) => _buildAssignmentCard(a, false)),
                    const SizedBox(height: 24),
                  ],
                  if (completed.isNotEmpty) ...[
                    const SectionHeader(title: 'Archive', color: Colors.green),
                    ...completed.map((a) => _buildAssignmentCard(a, false)),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAssignment(),
        backgroundColor: AluColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment, bool isOverdue) {
    Color priorityColor = assignment.priority == 'High'
        ? Colors.red
        : (assignment.priority == 'Medium' ? Colors.orange : Colors.green);

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
                        assignment.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: assignment.isCompleted
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.courseName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: assignment.isCompleted,
                  onChanged: (_) => _toggleComplete(assignment),
                  activeColor: Colors.green,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _dateFormat.format(assignment.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[700],
                        fontWeight: isOverdue
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () => _deleteAssignment(assignment.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

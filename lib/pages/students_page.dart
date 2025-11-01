import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/api_service.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.fetchStudents();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.instance.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Students',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final data = snapshot.data ?? [];
                  if (data.isEmpty)
                    return const Center(child: Text('No students'));
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Class ID')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: data
                          .map((s) => DataRow(cells: [
                                DataCell(Text(s.studentId)),
                                DataCell(Text(s.name)),
                                DataCell(Text('${s.classId ?? ''}')),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        final ok = await ApiService.instance
                                            .deleteStudent(s.studentId);
                                        if (ok && mounted) _refresh();
                                      },
                                    ),
                                  ],
                                )),
                              ]))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: idCtrl,
                    decoration: const InputDecoration(labelText: 'Student ID'),
                    validator: _v),
                TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: _v),
                TextFormField(
                    controller: classCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Class ID (optional)')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate())
                  Navigator.pop(context, true);
              },
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final classId = classCtrl.text.trim();
      final success = await ApiService.instance
          .addStudent(idCtrl.text.trim(), nameCtrl.text.trim(), classId);
      if (success && mounted) _refresh();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add student')));
      }
    }
  }

  String? _v(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}

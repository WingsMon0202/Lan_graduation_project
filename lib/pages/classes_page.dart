import 'package:flutter/material.dart';

import '../models/class_item.dart';
import '../services/api_service.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  late Future<List<ClassItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.fetchClasses();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.instance.fetchClasses();
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
                const Text('Classes',
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
              child: FutureBuilder<List<ClassItem>>(
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
                    return const Center(child: Text('No classes'));
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Class Name')),
                        DataColumn(label: Text('Teacher')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: data
                          .map((c) => DataRow(cells: [
                                DataCell(Text('${c.id}')),
                                DataCell(Text(c.className)),
                                DataCell(Text(c.teacher ?? '')),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        final ok = await ApiService.instance
                                            .deleteClass(int.parse(c.id));
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
    final nameCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Class'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Class Name'),
                    validator: _v),
                TextFormField(
                    controller: teacherCtrl,
                    decoration: const InputDecoration(labelText: 'Teacher')),
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
      final success = await ApiService.instance
          .addClass(nameCtrl.text.trim(), teacherCtrl.text.trim());
      if (success && mounted) _refresh();
    }
  }

  String? _v(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}

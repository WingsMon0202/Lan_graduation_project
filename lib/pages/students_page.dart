import 'package:flutter/material.dart';

import '../models/attendance_summary.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  late Future<List<Student>> _futureStudents;

  @override
  void initState() {
    super.initState();
    _futureStudents = ApiService.instance.fetchStudents();
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _futureStudents = ApiService.instance.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Management'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Students'),
              Tab(icon: Icon(Icons.fact_check), text: 'Attendance'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StudentsTab(),
            _AttendanceTab(),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// STUDENTS TAB (UI refined, logic unchanged)
// =====================================================
class _StudentsTab extends StatefulWidget {
  const _StudentsTab();

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  late Future<List<Student>> _futureStudents;

  @override
  void initState() {
    super.initState();
    _futureStudents = ApiService.instance.fetchStudents();
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _futureStudents = ApiService.instance.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _refreshStudents,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildStudentTable()),
        ],
      ),
    );
  }

  Widget _buildStudentTable() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<List<Student>>(
        future: _futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No students'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 58,
              dataRowHeight: 52,
              columnSpacing: 58,
              columns: const [
                DataColumn(label: Text('Student ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Actions')),
              ],
              rows: data
                  .map((s) => DataRow(cells: [
                        DataCell(Text(s.studentId)),
                        DataCell(Text(s.name)),
                        DataCell(Text(s.classId ?? '-')),
                        DataCell(
                          IconButton(
                            tooltip: 'Delete student',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await ApiService.instance
                                  .deleteStudent(s.studentId);
                              if (ok && mounted) _refreshStudents();
                            },
                          ),
                        ),
                      ]))
                  .toList(),
            ),
          );
        },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: _v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: classCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Class ID (optional)',
                    prefixIcon: Icon(Icons.class_),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final success = await ApiService.instance.addStudent(
        idCtrl.text.trim(),
        nameCtrl.text.trim(),
        classCtrl.text.trim(),
      );
      if (success && mounted) _refreshStudents();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add student')),
        );
      }
    }
  }

  String? _v(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// =====================================================
// ATTENDANCE TAB (UI refined, logic unchanged)
// =====================================================
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Aggregated attendance statistics per student',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildAttendanceTable()),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<List<AttendanceSummary>>(
        future: ApiService.instance.fetchAttendanceSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No attendance data'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 48,
              dataRowHeight: 52,
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('Student ID')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Total Checks')),
                DataColumn(label: Text('Present')),
                DataColumn(label: Text('Attendance (%)')),
              ],
              rows: data
                  .map((a) => DataRow(cells: [
                        DataCell(Text(a.studentId)),
                        DataCell(Text(a.classId.toString())),
                        DataCell(Text(a.date)),
                        DataCell(Text('${a.totalChecks}')),
                        DataCell(Text('${a.presentCount}')),
                        DataCell(
                          Text(a.attendanceRate.toStringAsFixed(1)),
                        ),
                      ]))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

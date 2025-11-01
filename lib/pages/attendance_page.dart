import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';
import '../services/api_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<AttendanceRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.fetchAttendance();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.instance.fetchAttendance();
    });
  }

  String _formatDateTime(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<AttendanceRecord>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record = data[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(record.status.substring(0, 1),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text('Student ID: ${record.studentId}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class ID: ${record.classId ?? 'N/A'}'),
                          Text(
                              'Timestamp: ${_formatDateTime(record.timestamp)}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          record.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            record.status.toLowerCase() == 'present'
                                ? Colors.green
                                : Colors.redAccent,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

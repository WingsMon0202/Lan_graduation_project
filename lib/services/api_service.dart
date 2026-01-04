import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';
import '../models/attendance_summary.dart';
import '../models/class_item.dart';
import '../models/dashboard_item.dart';
import '../models/student.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();

  String _baseUrl = 'http://127.0.0.1/attendance_api';

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? _baseUrl;
  }

  Future<List<Student>> fetchStudents() async {
    await _loadBaseUrl();
    final res = await http.get(Uri.parse('$_baseUrl/students.php'));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final jsonList = jsonDecode(res.body) as List;
    return jsonList.map((e) => Student.fromJson(e)).toList();
  }

  Future<bool> addStudent(String studentId, String name, String classId) async {
    await _loadBaseUrl();
    final payload = {
      'student_id': studentId,
      'name': name,
      'class_id': classId
    };
    final res = await http.post(
      Uri.parse('$_baseUrl/students_add.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<List<AttendanceSummary>> fetchAttendanceSummary({String? date}) async {
    await _loadBaseUrl();

    final uri = date == null
        ? Uri.parse('$_baseUrl/attendance_summary.php')
        : Uri.parse('$_baseUrl/attendance_summary.php?date=$date');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final jsonList = jsonDecode(res.body) as List;
    return jsonList.map((e) => AttendanceSummary.fromJson(e)).toList();
  }

  Future<bool> deleteStudent(String studentId) async {
    await _loadBaseUrl();
    final res = await http.post(
      Uri.parse('$_baseUrl/students_delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId}),
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<List<ClassItem>> fetchClasses() async {
    await _loadBaseUrl();
    final res = await http.get(Uri.parse('$_baseUrl/classes.php'));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final jsonList = jsonDecode(res.body) as List;
    return jsonList.map((e) => ClassItem.fromJson(e)).toList();
  }

  Future<bool> addClass(String className, String teacher) async {
    await _loadBaseUrl();
    final res = await http.post(
      Uri.parse('$_baseUrl/classes_add.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'class_name': className, 'teacher': teacher}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> deleteClass(int id) async {
    await _loadBaseUrl();
    final res = await http.post(
      Uri.parse('$_baseUrl/classes_delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<DashboardStats?> fetchDashboardStats() async {
    await _loadBaseUrl();
    final res = await http.get(Uri.parse('$_baseUrl/dashboard_stats.php'));
    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
      return DashboardStats.fromJson(jsonMap);
    }
    return null;
  }

  Future<List<AttendanceRecord>> fetchAttendance() async {
    await _loadBaseUrl();
    final res =
        await http.get(Uri.parse('$_baseUrl/attendance.php')); // GET list
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final jsonList = jsonDecode(res.body) as List;
    return jsonList.map((e) => AttendanceRecord.fromJson(e)).toList();
  }

  Future<bool> pushAttendance(
      String studentId, int classId, String status) async {
    await _loadBaseUrl();
    final res = await http.post(
      Uri.parse('$_baseUrl/attendance.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'student_id': studentId, 'class_id': classId, 'status': status}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}

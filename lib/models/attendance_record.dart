class AttendanceRecord {
  final String id;
  final String studentId;
  final String classId;
  final String status;
  final DateTime? timestamp;

  AttendanceRecord(
      {required this.id,
      required this.studentId,
      required this.classId,
      required this.status,
      this.timestamp});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['student_id'],
      classId: json['class_id'],
      status: json['status'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}

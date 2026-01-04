class AttendanceSummary {
  final String studentId;
  final int classId;
  final String date;
  final int totalChecks;
  final int presentCount;
  final double attendanceRate;

  AttendanceSummary({
    required this.studentId,
    required this.classId,
    required this.date,
    required this.totalChecks,
    required this.presentCount,
    required this.attendanceRate,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      studentId: json['student_id'],
      classId: json['class_id'],
      date: json['date'],
      totalChecks: int.parse(json['total_checks'].toString()),
      presentCount: int.parse(json['present_count'].toString()),
      attendanceRate: double.parse(json['attendance_rate'].toString()),
    );
  }
}

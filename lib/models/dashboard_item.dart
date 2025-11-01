class DashboardStats {
  final int totalStudents;
  final int todayPresent;
  final int todayAbsent;
  final int totalClasses;

  DashboardStats({
    required this.totalStudents,
    required this.todayPresent,
    required this.todayAbsent,
    required this.totalClasses,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: int.tryParse(json['total_students'].toString()) ?? 0,
      todayPresent: int.tryParse(json['today_present'].toString()) ?? 0,
      todayAbsent: int.tryParse(json['today_absent'].toString()) ?? 0,
      totalClasses: int.tryParse(json['total_classes'].toString()) ?? 0,
    );
  }
}

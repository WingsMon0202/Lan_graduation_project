class Student {
  final String studentId;
  final String name;
  final String classId;

  Student({required this.studentId, required this.name, required this.classId});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] ?? json['studentId'],
      name: json['name'],
      classId: json['class_id'],
    );
  }
}

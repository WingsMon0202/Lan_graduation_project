class ClassItem {
  final String id;
  final String className;
  final String? teacher;

  ClassItem({required this.id, required this.className, this.teacher});

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      className: json['class_name'],
      teacher: json['teacher'],
    );
  }
}

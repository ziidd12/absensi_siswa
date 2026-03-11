class TeacherProgressModel {
  final TeacherInfo teacher;
  final int total;
  final int assessed;
  final double percentage;

  TeacherProgressModel({
    required this.teacher,
    required this.total,
    required this.assessed,
    required this.percentage,
  });

  factory TeacherProgressModel.fromJson(Map<String, dynamic> json) {
    return TeacherProgressModel(
      teacher: TeacherInfo.fromJson(json['teacher'] ?? {}),
      total: json['total'] ?? 0,
      assessed: json['assessed'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class TeacherInfo {
  final int id;
  final String name;
  final String? nip;

  TeacherInfo({
    required this.id,
    required this.name,
    this.nip,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nip: json['nip'],
    );
  }
}
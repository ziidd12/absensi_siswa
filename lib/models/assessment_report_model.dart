import 'package:absensi_siswa/models/assessment_model.dart';

class StudentPerformanceReport {
  final double totalScore;
  final List<AssessmentReportData> categories;
  final List<Assessment> history;

  StudentPerformanceReport({
    required this.totalScore,
    required this.categories,
    required this.history,
  });

  factory StudentPerformanceReport.fromJson(Map<String, dynamic> json) {
    return StudentPerformanceReport(
      // Mengambil total_score dari JSON atau default ke 0.0
      totalScore: double.tryParse(json['total_score'].toString()) ?? 0.0,
      
      // Mengambil categories dari key 'scores' di JSON
      categories: (json['scores'] as List? ?? [])
          .map((i) => AssessmentReportData.fromJson(i))
          .toList(),
      
      // Mengambil history penilaian
      history: (json['history'] as List? ?? [])
          .map((i) => Assessment.fromJson(i))
          .toList(),
    );
  }
}

class AssessmentReportData {
  final String categoryName;
  final double averageScore;

  AssessmentReportData({
    required this.categoryName,
    required this.averageScore,
  });

  factory AssessmentReportData.fromJson(Map<String, dynamic> json) {
    return AssessmentReportData(
      categoryName: json['name'] ?? "-",
      averageScore: double.tryParse(json['average_score'].toString()) ?? 0.0,
    );
  }
}
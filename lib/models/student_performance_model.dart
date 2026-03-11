class StudentPerformanceModel {
  final StudentInfo student;
  final double totalScore;
  final List<CategoryScore> scores;
  final List<AssessmentHistory> history;

  StudentPerformanceModel({
    required this.student,
    required this.totalScore,
    required this.scores,
    required this.history,
  });

  factory StudentPerformanceModel.fromJson(Map<String, dynamic> json) {
    return StudentPerformanceModel(
      student: StudentInfo.fromJson(json['student'] ?? {}),
      totalScore: (json['total_score'] ?? 0).toDouble(),
      scores: (json['scores'] as List? ?? [])
          .map((e) => CategoryScore.fromJson(e))
          .toList(),
      history: (json['history'] as List? ?? [])
          .map((e) => AssessmentHistory.fromJson(e))
          .toList(),
    );
  }
}

class StudentInfo {
  final int id;
  final String name;
  final String nis;
  final String? kelas;

  StudentInfo({
    required this.id,
    required this.name,
    required this.nis,
    this.kelas,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nis: json['nis'] ?? '',
      kelas: json['kelas'],
    );
  }
}

class CategoryScore {
  final String name;
  final double averageScore;

  CategoryScore({
    required this.name,
    required this.averageScore,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      name: json['name'] ?? '',
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }
}

class AssessmentHistory {
  final int id;
  final String period;
  final String evaluatorName;
  final String? generalNotes;
  final double totalScore;
  final List<HistoryDetail> details;
  final String createdAt;

  AssessmentHistory({
    required this.id,
    required this.period,
    required this.evaluatorName,
    this.generalNotes,
    required this.totalScore,
    required this.details,
    required this.createdAt,
  });

  factory AssessmentHistory.fromJson(Map<String, dynamic> json) {
    return AssessmentHistory(
      id: json['id'] ?? 0,
      period: json['period'] ?? '',
      evaluatorName: json['evaluator_name'] ?? '',
      generalNotes: json['general_notes'],
      totalScore: (json['total_score'] ?? 0).toDouble(),
      details: (json['details'] as List? ?? [])
          .map((e) => HistoryDetail.fromJson(e))
          .toList(),
      createdAt: json['created_at'] ?? '',
    );
  }
}

class HistoryDetail {
  final String category;
  final double score;

  HistoryDetail({
    required this.category,
    required this.score,
  });

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    return HistoryDetail(
      category: json['category'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}
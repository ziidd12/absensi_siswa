class ClassStatisticsModel {
  final String kelas;
  final int totalSiswa;
  final double classAverage;
  final StudentStatistic? topStudent;
  final StudentStatistic? lowestStudent;
  final List<StudentStatistic> statistics;

  ClassStatisticsModel({
    required this.kelas,
    required this.totalSiswa,
    required this.classAverage,
    this.topStudent,
    this.lowestStudent,
    required this.statistics,
  });

  factory ClassStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ClassStatisticsModel(
      kelas: json['kelas'] ?? '',
      totalSiswa: json['total_siswa'] ?? 0,
      classAverage: (json['class_average'] ?? 0).toDouble(),
      topStudent: json['top_student'] != null
          ? StudentStatistic.fromJson(json['top_student'])
          : null,
      lowestStudent: json['lowest_student'] != null
          ? StudentStatistic.fromJson(json['lowest_student'])
          : null,
      statistics: (json['statistics'] as List? ?? [])
          .map((e) => StudentStatistic.fromJson(e))
          .toList(),
    );
  }
}

class StudentStatistic {
  final int siswaId;
  final String nama;
  final String nis;
  final double averageScore;
  final int totalAssessments;

  StudentStatistic({
    required this.siswaId,
    required this.nama,
    required this.nis,
    required this.averageScore,
    required this.totalAssessments,
  });

  factory StudentStatistic.fromJson(Map<String, dynamic> json) {
    return StudentStatistic(
      siswaId: json['siswa_id'] ?? 0,
      nama: json['nama'] ?? '',
      nis: json['nis'] ?? '',
      averageScore: (json['average_score'] ?? 0).toDouble(),
      totalAssessments: json['total_assessments'] ?? 0,
    );
  }
}
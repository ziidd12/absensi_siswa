class TeacherDashboardModel {
  final int totalSiswa;
  final int dinilaiCount;
  final double progress;
  final List<SiswaPenilaian> belumDinilai;
  final List<SiswaPenilaian> sudahDinilai;

  TeacherDashboardModel({
    required this.totalSiswa,
    required this.dinilaiCount,
    required this.progress,
    required this.belumDinilai,
    required this.sudahDinilai,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      totalSiswa: json['total_siswa'] ?? 0,
      dinilaiCount: json['dinilai_count'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      belumDinilai: (json['belum_dinilai'] as List? ?? [])
          .map((e) => SiswaPenilaian.fromJson(e))
          .toList(),
      sudahDinilai: (json['sudah_dinilai'] as List? ?? [])
          .map((e) => SiswaPenilaian.fromJson(e))
          .toList(),
    );
  }
}

class SiswaPenilaian {
  final int id;
  final String nama;
  final String nis;
  final String? foto;
  final String? kelas;
  final double? nilaiTerakhir;
  final String? tanggalDinilai;

  SiswaPenilaian({
    required this.id,
    required this.nama,
    required this.nis,
    this.foto,
    this.kelas,
    this.nilaiTerakhir,
    this.tanggalDinilai,
  });

  factory SiswaPenilaian.fromJson(Map<String, dynamic> json) {
    return SiswaPenilaian(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['nama_siswa'] ?? '',
      nis: json['nis'] ?? '-',
      foto: json['foto'],
      kelas: json['kelas'],
      nilaiTerakhir: json['nilai_terakhir'] != null 
          ? (json['nilai_terakhir'] as num).toDouble() 
          : null,
      tanggalDinilai: json['tanggal_dinilai'],
    );
  }
}

class AssessmentCategoryModel {
  final int id;
  final String name;
  final String? description;

  AssessmentCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory AssessmentCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssessmentCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class KategoriPenilaian {
  final int id;
  final String name;
  final String? description;

  KategoriPenilaian({
    required this.id,
    required this.name,
    this.description,
  });

  factory KategoriPenilaian.fromJson(Map<String, dynamic> json) {
    return KategoriPenilaian(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

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
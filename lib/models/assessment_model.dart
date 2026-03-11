class Assessment {
  final int? id;
  final int? evaluatorId;
  final int evaluateeId;
  final int tahunAjaranId;
  final String assessmentDate;
  final String? generalNotes;
  final List<AssessmentDetail>? details;

  Assessment({
    this.id,
    this.evaluatorId,
    required this.evaluateeId,
    required this.tahunAjaranId,
    required this.assessmentDate,
    this.generalNotes,
    this.details,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      evaluatorId: json['evaluator_id'],
      evaluateeId: json['evaluatee_id'],
      tahunAjaranId: json['tahun_ajaran_id'],
      assessmentDate: json['assessment_date'],
      generalNotes: json['general_notes'],
      details: json['details'] != null
          ? (json['details'] as List)
              .map((i) => AssessmentDetail.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evaluatee_id': evaluateeId,
      'tahun_ajaran_id': tahunAjaranId,
      'assessment_date': assessmentDate,
      'general_notes': generalNotes,
      // Sesuai controller: scores.*.question_id dan scores.*.score
      'scores': details?.map((d) => d.toScoreJson()).toList(),
    };
  }
}

class AssessmentDetail {
  final int questionId;
  final int score;
  final String? questionText;

  AssessmentDetail({
    required this.questionId,
    required this.score,
    this.questionText,
  });

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      questionId: json['question_id'],
      score: int.parse(json['score'].toString()),
      // Mengambil teks pertanyaan jika ada (dari relasi details.question)
      questionText: json['question'] != null ? json['question']['question_text'] : null,
    );
  }

  Map<String, dynamic> toScoreJson() {
    return {
      'question_id': questionId,
      'score': score,
    };
  }
}
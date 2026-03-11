class AssessmentCategory {
  final int id;
  final String name;
  final String? description;
  final String type;
  final bool isActive;
  final int? questionsCount; 
  // 1. TAMBAHKAN INI: Untuk menampung list pertanyaan aslinya
  final List<AssessmentQuestion> questions; 

  AssessmentCategory({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.isActive,
    this.questionsCount,
    required this.questions, // 2. Tambahkan di constructor
  });

  factory AssessmentCategory.fromJson(Map<String, dynamic> json) {
    return AssessmentCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'] ?? 'student',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      questionsCount: json['questions_count'],
      // 3. TAMBAHKAN MAPPING INI: Mengubah list JSON menjadi list Object
      questions: (json['questions'] as List? ?? [])
          .map((q) => AssessmentQuestion.fromJson(q))
          .toList(),
    );
  }
}

// 4. BUAT CLASS BARU INI: Jika belum ada di file yang sama
class AssessmentQuestion {
  final int id;
  final String questionText;

  AssessmentQuestion({
    required this.id, 
    required this.questionText
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'],
      // Laravel biasanya kirim 'question_text', tapi cek lagi di JSON kamu
      questionText: json['question_text'] ?? json['question'] ?? "-",
    );
  }
}
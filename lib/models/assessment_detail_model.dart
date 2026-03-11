class AssessmentDetailModel {
  final int id;
  final int assessmentId;
  final int categoryId;
  final double score;
  final String? categoryName;

  AssessmentDetailModel({
    required this.id,
    required this.assessmentId,
    required this.categoryId,
    required this.score,
    this.categoryName,
  });

  factory AssessmentDetailModel.fromJson(Map<String, dynamic> json) {
    return AssessmentDetailModel(
      id: json['id'] ?? 0,
      assessmentId: json['assessment_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'category_id': categoryId,
      'score': score,
      'category_name': categoryName,
    };
  }
}
class AssessmentCategoryModel {
  final int id;
  final String name;
  final String? description;
  final int detailsCount;

  AssessmentCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.detailsCount = 0,
  });

  factory AssessmentCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssessmentCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      detailsCount: json['details_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'details_count': detailsCount,
    };
  }
}
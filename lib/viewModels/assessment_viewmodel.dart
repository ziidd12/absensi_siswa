import 'package:absensi_siswa/models/assessment_category_model.dart';
import 'package:absensi_siswa/models/assessment_model.dart' hide AssessmentCategoryModel;
import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class AssessmentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  List<AssessmentCategoryModel> _categories = [];
  StudentPerformanceModel? _studentPerformance;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AssessmentCategoryModel> get categories => _categories;
  StudentPerformanceModel? get studentPerformance => _studentPerformance;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await ApiService.getAssessmentCategories();
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudentPerformance({int? studentId}) async {
    _setLoading(true);
    try {
      _studentPerformance = await ApiService.getStudentPerformance(studentId: studentId);
    } catch (e) {
      _errorMessage = 'Gagal memuat performa: $e';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
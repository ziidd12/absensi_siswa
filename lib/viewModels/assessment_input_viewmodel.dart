import 'package:absensi_siswa/models/assessment_category_model.dart';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class AssessmentInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  List<AssessmentCategoryModel> _categories = [];
  Map<int, double> _selectedScores = {};
  String? _generalNotes;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<AssessmentCategoryModel> get categories => _categories;
  Map<int, double> get selectedScores => _selectedScores;
  String? get generalNotes => _generalNotes;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await ApiService.getAssessmentCategories();
      for (var cat in _categories) {
        _selectedScores[cat.id] = 3.0;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
    } finally {
      _setLoading(false);
    }
  }

  void setScore(int categoryId, double score) {
    _selectedScores[categoryId] = score;
    notifyListeners();
  }

  void setGeneralNotes(String notes) {
    _generalNotes = notes;
    notifyListeners();
  }

  Future<bool> submitAssessment(int siswaId) async {
    if (_selectedScores.isEmpty) {
      _errorMessage = 'Pilih minimal satu penilaian';
      return false;
    }

    _setLoading(true);
    try {
      final result = await ApiService.submitPenilaianGuru(
        siswaId: siswaId,
        scores: _selectedScores,
        catatan: _generalNotes,
      );
      
      if (result['status'] == 'success') {
        _successMessage = 'Penilaian berhasil disimpan';
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal menyimpan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearScores() {
    _selectedScores.clear();
    _generalNotes = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
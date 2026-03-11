import 'package:absensi_siswa/models/assessment_model.dart';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class FormPenilaianViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  
  List<KategoriPenilaian> _kategoriList = [];
  Map<int, double> _ratings = {};
  String _catatan = '';
  
  SiswaPenilaian? _siswa;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<KategoriPenilaian> get kategoriList => _kategoriList;
  Map<int, double> get ratings => _ratings;
  String get catatan => _catatan;
  SiswaPenilaian? get siswa => _siswa;

  // Constructor tanpa parameter
  FormPenilaianViewModel() {
    _loadInitialData();
  }

  // Method untuk set siswa (dipanggil dari screen)
  void setSiswa(SiswaPenilaian siswa) {
    _siswa = siswa;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    _setLoading(true);
    try {
      _kategoriList = await ApiService.getKategoriPenilaian();
      for (var kategori in _kategoriList) {
        _ratings[kategori.id] = 3.0;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setRating(int categoryId, double rating) {
    _ratings[categoryId] = rating;
    notifyListeners();
  }

  void setCatatan(String value) {
    _catatan = value;
    notifyListeners();
  }

  Future<bool> submitPenilaian() async {
    if (_siswa == null) {
      _errorMessage = 'Pilih siswa terlebih dahulu';
      return false;
    }

    if (_ratings.isEmpty) {
      _errorMessage = 'Belum ada penilaian';
      return false;
    }

    _setSubmitting(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await ApiService.submitPenilaianGuru(
        siswaId: _siswa!.id,
        scores: _ratings,
        catatan: _catatan,
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
      _setSubmitting(false);
    }
  }

  void resetForm() {
    for (var kategori in _kategoriList) {
      _ratings[kategori.id] = 3.0;
    }
    _catatan = '';
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
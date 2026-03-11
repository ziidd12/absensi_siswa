import 'package:absensi_siswa/models/assessment_category_model.dart';
import 'package:absensi_siswa/models/assessment_model.dart';
import 'package:absensi_siswa/models/assessment_report_model.dart';
import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';

class AssessmentViewModel extends ChangeNotifier {
  // Menggunakan ApiService secara static sesuai dengan definisi di service layer
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 1. Data Form Struktur (Kategori & Pertanyaan)
  List<AssessmentCategory> _categories = [];
  List<AssessmentCategory> get categories => _categories;

  // 2. Data Siswa untuk dinilai
  List<dynamic> _students = [];
  List<dynamic> get students => _students;

  // 3. Data Laporan & Performa
  StudentPerformanceReport? _performanceReport;
  StudentPerformanceReport? get performanceReport => _performanceReport;

  // 4. Data Statistik Guru
  Map<String, dynamic> _teacherProgress = {};
  Map<String, dynamic> get teacherProgress => _teacherProgress;

  // --- GETTERS UNTUK UI ---

  /// Mengambil total skor rata-rata untuk TotalScoreCard
  double get totalScore => _performanceReport?.totalScore ?? 0.0;

  /// Mengambil list kategori untuk Radar Chart dan Rincian Skor
  List<AssessmentReportData> get reportData => _performanceReport?.categories ?? [];

  // ------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    // Menggunakan microtask agar aman dipanggil saat build process
    Future.microtask(() => notifyListeners());
  }

  // --- API METHODS ---

  /// Mengambil Kategori & Struktur Pertanyaan
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      _categories = await ApiService.getAssessmentForm();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat kategori: $e";
      debugPrint("❌ Error fetchCategories: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil Daftar Siswa yang akan dinilai
  Future<void> fetchStudentsToAssess(int tahunAjaranId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getStudentsToAssess(tahunAjaranId);
      // PASTIKAN: Data di-assign ulang, bukan di-add
      _students = response; 
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Ini akan memicu UI untuk build ulang
    }
  }

  /// Menyimpan Penilaian Baru
  Future<bool> saveAssessment({
    required int evaluateeId,
    required int tahunAjaranId,
    required List<AssessmentDetail> details,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      // 1. Bungkus data ke dalam Model Assessment agar rapi
      final assessmentData = Assessment(
        evaluateeId: evaluateeId,
        tahunAjaranId: tahunAjaranId,
        assessmentDate: DateTime.now().toIso8601String().split('T')[0],
        generalNotes: notes,
        details: details,
      );

      // 2. Kirim object secara utuh ke ApiService
      final response = await ApiService.submitAssessment(assessmentData);
      
      if (response['status'] == 'success') {
        _errorMessage = null;
        
        // Refresh statistik dan daftar siswa agar UI terupdate
        await fetchTeacherProgress();
        await fetchStudentsToAssess(tahunAjaranId); 
        
        return true;
      } else {
        _errorMessage = response['message'] ?? "Gagal menyimpan data";
        return false;
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      debugPrint("❌ Error saveAssessment: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil Laporan Performa (Radar Chart + History)
  /// Identik dengan fungsi fetchStudentReport yang dipanggil di View
  Future<void> fetchStudentPerformance({int? studentId, int? tahunAjaranId}) async {
    _setLoading(true);
    try {
      _performanceReport = await ApiService.getPerformanceRadar(
        studentId: studentId,
        tahunAjaranId: tahunAjaranId,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat laporan: $e";
      debugPrint("❌ Error fetchStudentPerformance: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Alias fungsi agar sesuai dengan pemanggilan fetchStudentReport di View
  Future<void> fetchStudentReport(int? tahunAjaranId, int? studentId) async {
    await fetchStudentPerformance(studentId: studentId, tahunAjaranId: tahunAjaranId);
  }

  /// Mengambil Statistik Progres Guru
  Future<void> fetchTeacherProgress() async {
    try {
      _teacherProgress = await ApiService.getTeacherStats();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetch teacher stats: $e");
    }
  }
}
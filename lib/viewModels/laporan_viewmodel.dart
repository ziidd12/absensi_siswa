import 'package:absensi_siswa/models/laporan_model.dart' as model;
import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class LaporanViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  model.LaporanModel? _reportData;
  model.LaporanModel? get reportData => _reportData;

  // Pagination State
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  // Hitung total halaman (asumsi per page dari API adalah 10 atau 15)
  // Anda bisa menyesuaikan ini berdasarkan field 'total_data' dari API
  int get totalPages {
    int total = _reportData?.data?.totalData ?? 0;
    if (total == 0) return 1;
    return (total / 5).ceil(); 
  }

  List<dynamic> _listTahunAjaran = [];
  List<dynamic> get listTahunAjaran => _listTahunAjaran;

  String? selectedTingkat;
  String? selectedJurusan;
  String? selectedStatus;
  String? selectedTahunAjaranId;

  Future<void> fetchLaporan({int page = 1}) async {
    _isLoading = true;
    _currentPage = page; // Set halaman aktif
    notifyListeners();

    try {
      _reportData = await ApiService.fetchLaporanKehadiran(
        tingkat: selectedTingkat,
        jurusan: selectedJurusan,
        status: selectedStatus,
        tahunAjaranId: selectedTahunAjaranId,
        page: _currentPage, // Kirim ke ApiService
      );
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) fetchLaporan(page: _currentPage + 1);
  }

  void prevPage() {
    if (_currentPage > 1) fetchLaporan(page: _currentPage - 1);
  }

  Future<void> initMasterData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _listTahunAjaran = await ApiService.fetchTahunAjaran();
      if (_listTahunAjaran.isNotEmpty) {
        final activeYear = _listTahunAjaran.firstWhere(
          (e) => e['is_active'] == 1 || e['is_active'] == true,
          orElse: () => _listTahunAjaran.first,
        );
        selectedTahunAjaranId = activeYear['id'].toString();
      }
      await fetchLaporan(); // Panggil fetch setelah init master
    } catch (e) {
      debugPrint("Gagal load master data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PERBAIKAN DI SINI:
  // Pastikan fungsi ini bisa dipanggil tanpa argumen
  Future<Uint8List> downloadLaporanPdf() async {
    try {
      // Menggunakan state filter yang ada di ViewModel
      final pdfBytes = await ApiService.downloadLaporanPdf(
        tingkat: selectedTingkat,
        jurusan: selectedJurusan,
        status: selectedStatus,
        // Jika API Anda butuh tahun_ajaran_id untuk PDF, tambahkan di bawah:
        // tahunAjaranId: selectedTahunAjaranId, 
      );
      return pdfBytes;
    } catch (e) {
      throw Exception('Gagal mengunduh PDF: $e');
    }
  }

  // Statistik per kelas untuk Grafik (Sekarang ambil data utuh dari API)
  Map<String, int> get perClassStats {
    // Jika API mengirim data statistik_grafik, gunakan itu. 
    // Jika tidak ada, baru fallback ke absensi (atau kosongkan).
    return _reportData?.data?.statistikGrafik ?? {};
  }
}
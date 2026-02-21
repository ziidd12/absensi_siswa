// lib/viewmodels/laporan_viewmodel.dart

import 'dart:io';
import 'package:absensi_siswa/models/laporan_model.dart' as model;
import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class LaporanViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  model.LaporanModel? _reportData;
  model.LaporanModel? get reportData => _reportData;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  // Hitung total halaman berdasarkan total data dari API (asumsi 5 data per halaman)
  int get totalPages {
    int total = _reportData?.data?.totalData ?? 0;
    if (total == 0) return 1;
    return (total / 5).ceil(); 
  }

  List<dynamic> _listTahunAjaran = [];
  List<dynamic> get listTahunAjaran => _listTahunAjaran;

  List<String> _listTingkat = [];
  List<String> get listTingkat => _listTingkat;

  List<String> _listJurusan = [];
  List<String> get listJurusan => _listJurusan;

  String? selectedTingkat;
  String? selectedJurusan;
  String? selectedStatus;
  String? selectedTahunAjaranId;

  // --- FUNGSI PAGINATION (TAMBAHKAN INI) ---
  void nextPage() {
    if (_currentPage < totalPages) {
      fetchLaporan(page: _currentPage + 1);
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      fetchLaporan(page: _currentPage - 1);
    }
  }
  // ----------------------------------------

  Future<void> fetchLaporan({int page = 1}) async {
    _isLoading = true;
    _currentPage = page; // Update halaman aktif
    notifyListeners();

    try {
      _reportData = await ApiService.fetchLaporanKehadiran(
        tingkat: selectedTingkat,
        jurusan: selectedJurusan,
        status: selectedStatus,
        tahunAjaranId: selectedTahunAjaranId,
        page: _currentPage,
      );
    } catch (e) {
      debugPrint("Error Fetch Laporan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initMasterData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final masterData = await ApiService.fetchMasterData();
      
      _listTahunAjaran = masterData['daftar_tahun_ajaran'] ?? [];
      List<dynamic> daftarKelas = masterData['daftar_kelas'] ?? [];

      _listTingkat = daftarKelas.map((e) => e['tingkat'].toString()).toSet().toList()..sort();
      _listJurusan = daftarKelas.map((e) => e['jurusan'].toString()).toSet().toList()..sort();

      if (_listTahunAjaran.isNotEmpty) {
        final activeYear = _listTahunAjaran.firstWhere(
          (e) => e['is_active'] == 1 || e['is_active'] == true,
          orElse: () => _listTahunAjaran.first,
        );
        selectedTahunAjaranId = activeYear['id'].toString();
      }

      await fetchLaporan(); 
    } catch (e) {
      debugPrint("Error Init Master: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters untuk Filter
  void setTingkat(String? val) { selectedTingkat = val; _currentPage = 1; fetchLaporan(); }
  void setJurusan(String? val) { selectedJurusan = val; _currentPage = 1; fetchLaporan(); }
  void setStatus(String? val) { selectedStatus = val; _currentPage = 1; fetchLaporan(); }
  void setTahunAjaran(String? val) { selectedTahunAjaranId = val; _currentPage = 1; fetchLaporan(); }

  // Fungsi Download PDF
  Future<void> downloadAndOpenFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final bytes = await ApiService.downloadLaporanPdf(
        tingkat: selectedTingkat,
        jurusan: selectedJurusan,
        status: selectedStatus,
        tahunAjaranId: selectedTahunAjaranId,
      );

      final dir = await getTemporaryDirectory();
      final fileName = "Laporan_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint("Gagal Download: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, int> get perClassStats {
    final data = _reportData?.data?.statistikGrafik;
    if (data == null) return {};
    return Map<String, int>.from(data);
  }
}
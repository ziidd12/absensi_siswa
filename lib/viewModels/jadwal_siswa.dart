import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/models/jadwal_model.dart';

class JadwalViewModel extends ChangeNotifier {
  List<JadwalModel> _listJadwal = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<JadwalModel> get listJadwal => _listJadwal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchJadwal() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService.getJadwalHariIni();
      _listJadwal = data;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error Fetch Jadwal: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper untuk mendapatkan jadwal saat ini (untuk keperluan Absensi)
  JadwalModel? get activeJadwal {
    // Logika tambahan jika ingin mencari jadwal yang sedang LIVE secara otomatis
    return _listJadwal.firstWhere(
      (j) => true, // Sesuaikan dengan logika waktu jika perlu
      orElse: () => _listJadwal.first, 
    );
  }
}
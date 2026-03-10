import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';

class Pelajaran {
  final String nama;
  final String jam;
  bool isAbsen;

  Pelajaran({required this.nama, required this.jam, this.isAbsen = false});
}

class KehadiranViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Data Sesi untuk Guru
  attendanceSessionModel? _sessionData;
  attendanceSessionModel? get sessionData => _sessionData;

  // Data Jadwal untuk Siswa (Testing Malam Ini)
  List<Pelajaran> _jadwalSiswa = [
    Pelajaran(nama: "Matematika", jam: "07.10 - 09.10"),
    Pelajaran(nama: "B. Indonesia", jam: "09.25 - 11.25"),
    Pelajaran(nama: "Konsentrasi RPL", jam: "12.30 - 14.30"),
    Pelajaran(nama: "BK", jam: "14.30 - 15.10"),
  ];
  List<Pelajaran> get jadwalSiswa => _jadwalSiswa;

  // ===================== FUNGSI GURU =====================
  Future<void> createSession(int jadwalId) async {
    _isLoading = true;
    _sessionData = null;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _sessionData = await ApiService.createAttendanceSession(jadwalId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== FUNGSI SISWA =====================
  Future<attendanceScanModel?> scanQR(String token, double lat, double lng, String namaMapel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.scanQR(token, lat, lng);
      
      if (result != null) {
        int index = _jadwalSiswa.indexWhere((p) => p.nama == namaMapel);
        if (index != -1) {
          _jadwalSiswa[index].isAbsen = true;
        }
      }
      return result;
    } catch (e) {
      _errorMessage = 'Gagal Absen: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
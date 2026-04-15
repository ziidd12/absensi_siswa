import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/service/api_service.dart'; 
import 'package:absensi_siswa/utils/token_storage.dart';

// --- MODEL SISWA (LOKAL UNTUK UI GURU) ---
class Siswa {
  final int id;
  final String nama;
  String status;
  bool isLocked;

  Siswa({
    required this.id, 
    required this.nama, 
    this.status = 'Belum',
    this.isLocked = false,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'] ?? 0,
      nama: json['nama_siswa'] ?? json['nama'] ?? 'Tanpa Nama',
      status: json['status_absen']?.toString() ?? 'Belum', 
      isLocked: json['is_locked'] == true || json['is_locked'] == 1, 
    );
  }
}

// --- MODEL PELAJARAN (DUMMY/LOKAL) ---
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

  List<dynamic> _riwayatReal = [];
  List<dynamic> get riwayatReal => _riwayatReal;
  
  // Setter untuk error message
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  // Gunakan PascalCase sesuai model terbaru
  AttendanceSessionModel? _sessionData;
  AttendanceSessionModel? get sessionData => _sessionData;

  // Data Jadwal Dummy untuk UI Siswa
  List<Pelajaran> _jadwalSiswa = [
    Pelajaran(nama: "Matematika", jam: "07:15 - 09:15"),
    Pelajaran(nama: "B. Indonesia", jam: "09:25 - 11:25"),
    Pelajaran(nama: "Konsentrasi RPL", jam: "12:30 - 14:30"),
  ];
  List<Pelajaran> get jadwalSiswa => _jadwalSiswa;

  List<Siswa> _daftarSiswa = [];
  List<Siswa> _filteredSiswa = []; 
  String _searchQuery = "";

  List<Siswa> get daftarSiswa => _searchQuery.isEmpty ? _daftarSiswa : _filteredSiswa;

  // ===================== FUNGSI RIWAYAT (SISWA) =====================
  Future<void> fetchRiwayatSiswa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Menggunakan endpoint yang sudah disesuaikan di Laravel/API
      final result = await ApiService.get('attendance/history');
      if (result['status'] == 'success') {
        _riwayatReal = result['data'];
      } else {
        _errorMessage = "Gagal mengambil riwayat";
      }
    } catch (e) {
      _errorMessage = "Koneksi Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== FUNGSI PENCARIAN =====================
  void searchSiswa(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSiswa = [];
    } else {
      _filteredSiswa = _daftarSiswa
          .where((s) => s.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ===================== FUNGSI AMBIL DAFTAR SISWA (GURU) =====================
  Future<void> fetchSiswaByKelas(String namaKelas, {int? jadwalId}) async {
    _isLoading = true;
    _errorMessage = null; 
    _daftarSiswa = []; 
    _filteredSiswa = [];
    notifyListeners();

    try {
      String endpoint = 'siswa-by-kelas/${Uri.encodeComponent(namaKelas)}';
      if (jadwalId != null) endpoint += "?jadwal_id=$jadwalId";
      
      final result = await ApiService.get(endpoint);

      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        _daftarSiswa = data.map((item) => Siswa.fromJson(item)).toList();
      } else {
        _errorMessage = result['message'] ?? "Gagal memuat data siswa";
      }
    } catch (e) {
      _errorMessage = "Koneksi bermasalah: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSiswaStatus(int index, String status) {
    Siswa siswaTarget = daftarSiswa[index];
    int originalIndex = _daftarSiswa.indexOf(siswaTarget);

    if (originalIndex != -1 && !_daftarSiswa[originalIndex].isLocked) {
      _daftarSiswa[originalIndex].status = status;
      notifyListeners();
    }
  }

  // ===================== FUNGSI BUAT SESI QR (GURU) =====================
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

  // ===================== FUNGSI SCAN QR (SISWA) - TANPA LOKASI =====================
  Future<AttendanceScanModel?> scanQR(String token) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Memanggil ApiService.scanQR yang sudah kita update (hanya kirim token)
      final result = await ApiService.scanQR(token);
      
      if (result != null) {
        if (result.status == 'success') {
          _errorMessage = result.message; // Menyimpan pesan sukses/info poin
        } else {
          _errorMessage = result.message; // Menyimpan pesan error dari Laravel
        }
        return result;
      }
      return null;
    } catch (e) {
      _errorMessage = "Terjadi kendala saat menghubungi server.";
      notifyListeners();
      return null;
    }
  }

  // ===================== FUNGSI SIMPAN MANUAL (GURU) =====================
  Future<bool> simpanKehadiran(int jadwalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Mengirimkan jadwalId dan list _daftarSiswa ke ApiService
      bool sukses = await ApiService.saveManualAttendance(jadwalId, _daftarSiswa);
      if (!sukses) _errorMessage = "Gagal menyimpan absensi manual";
      return sukses;
    } catch (e) {
      _errorMessage = "Gagal menyimpan ke server: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
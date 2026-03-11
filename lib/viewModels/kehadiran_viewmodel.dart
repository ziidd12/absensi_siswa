import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/service/api_service.dart'; // Sesuaikan folder service/services
import 'package:absensi_siswa/utils/token_storage.dart';

// --- MODEL SISWA ---
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

// --- MODEL PELAJARAN ---
class Pelajaran {
  final String nama;
  final String jam;
  bool isAbsen;

  Pelajaran({required this.nama, required this.jam, this.isAbsen = false});
}

class KehadiranViewmodel extends ChangeNotifier {
  // 1. Inisialisasi ApiService agar tidak Error "isn't defined"
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 2. Definisi variabel ErrorMessage dengan benar
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Setter untuk mempermudah update error dari luar/dalam
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  attendanceSessionModel? _sessionData;
  attendanceSessionModel? get sessionData => _sessionData;

  // Data Dummy untuk UI Siswa (Bisa kamu hapus jika nanti sudah pakai API Jadwal)
  List<Pelajaran> _jadwalSiswa = [
    Pelajaran(nama: "Matematika", jam: "07.10 - 09.10"),
    Pelajaran(nama: "B. Indonesia", jam: "09.25 - 11.25"),
    Pelajaran(nama: "Konsentrasi RPL", jam: "12.30 - 14.30"),
    Pelajaran(nama: "BK", jam: "14.30 - 15.10"),
  ];
  List<Pelajaran> get jadwalSiswa => _jadwalSiswa;

  List<Siswa> _daftarSiswa = [];
  List<Siswa> _filteredSiswa = []; 
  String _searchQuery = "";

  List<Siswa> get daftarSiswa => _searchQuery.isEmpty ? _daftarSiswa : _filteredSiswa;

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

  // ===================== FUNGSI AMBIL DATA SISWA (GURU) =====================
  Future<void> fetchSiswaByKelas(String namaKelas, {int? jadwalId}) async {
    _isLoading = true;
    _errorMessage = null; 
    _daftarSiswa = []; 
    _filteredSiswa = [];
    _searchQuery = ""; 
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      
      String url = "${ApiService.baseUrl}/siswa-by-kelas/${Uri.encodeComponent(namaKelas)}";
      if (jadwalId != null) {
        url += "?jadwal_id=$jadwalId";
      }
      
      final uri = Uri.parse(url);
      print("🔗 REQUEST KE: $uri");

      final response = await http.get(
        uri, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', 
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('data')) {
          final List<dynamic> data = responseBody['data'];
          _daftarSiswa = data.map((item) => Siswa.fromJson(item)).toList();
        }
      } else if (response.statusCode == 404) {
        _errorMessage = "Kelas '$namaKelas' tidak ditemukan.";
      } else {
        final errJson = json.decode(response.body);
        _errorMessage = errJson['message'] ?? "Server Error (${response.statusCode})";
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

  // ===================== FUNGSI SCAN QR (SISWA) =====================
  Future<bool?> scanQR(String token, double lat, double long, String mapel) async {
    _errorMessage = null; // Reset error sebelum mulai scan
    notifyListeners();

    try {
      // Memanggil fungsi postAbsensi dari ApiService yang sudah kita inisialisasi
      final response = await _apiService.postAbsensi(token, lat, long);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        // Menangkap pesan "Anda bukan siswa di kelas ini!" dari Laravel
        _errorMessage = data['message'] ?? "Terjadi kesalahan";
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = "Koneksi ke server bermasalah, Lek!";
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
      bool sukses = await ApiService.saveManualAttendance(jadwalId, _daftarSiswa);
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
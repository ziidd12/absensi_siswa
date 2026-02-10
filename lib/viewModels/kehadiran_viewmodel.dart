import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/service/api_service.dart';
import 'package:flutter/material.dart';

class KehadiranViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  attendanceSessionModel? _sessionData;
  attendanceSessionModel? get sessionData => _sessionData;

  List<dynamic> _historyGuru = [];
  List<dynamic> get historyGuru => _historyGuru;

  // List<HistoryModel> _historyList = [];
  // List<HistoryModel> get historyList => _historyList;

  // Future<void> fetchHistory() async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     _historyList = await ApiService.fetchRiwayat();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     debugPrint("Error Fetch History: $e");
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Guru: Membuat Sesi QR
  Future<void> createSession(int jadwalId) async {
    _isLoading = true;
    _sessionData = null; // 1. Reset data lama agar QR tidak "nyangkut"
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 2. Ambil data baru dari API
      _sessionData = await ApiService.createAttendanceSession(jadwalId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Siswa: Scan QR
  Future<attendanceScanModel?> scanQR(String token, double lat, double lng) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.scanQR(token, lat, lng);
      return result;
    } catch (e) {
      _errorMessage = 'Gagal Absen: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> fetchReportGuru({required String tahunAjaranId, required String kelasId}) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     final response = await ApiService.fetchReportGuru(tahunAjaranId, kelasId);
  //     _historyGuru = response;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> exportToExcel({required String tahunAjaranId, required String kelasId}) async {
  //   try {
  //     await ApiService.downloadReport(tahunAjaranId, kelasId);
  //   } catch (e) {
  //     _errorMessage = "Gagal mengunduh file: $e";
  //     notifyListeners();
  //   }
  // }
}
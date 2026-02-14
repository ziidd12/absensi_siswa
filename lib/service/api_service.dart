import 'dart:convert';
// import 'dart:io';
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const String baseUrl = 'https://calculous-unsculptured-ngan.ngrok-free.dev/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final request = http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    return _handleApiRequest(request, 'mengambil', endpoint);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final request = http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleApiRequest(request, 'mengirim', endpoint);
  }

  static Future<dynamic> _handleApiRequest(
      Future<http.Response> request, String operationType, String endpoint) async {
    try {
      final response = await request.timeout(const Duration(seconds: 15));
      print("📤 DEBUG $endpoint [${response.statusCode}]: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'];
        }
        return decoded; 
      } else {
        throw Exception('Gagal $operationType $endpoint. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $operationType $endpoint: $e');
    }
  }

  // --------------------------------------------------------------------------
  // --- ATTENDANCE (SESSION & SCAN) ---
  // --------------------------------------------------------------------------

  static Future<attendanceSessionModel?> createAttendanceSession(int jadwalId) async {
    final token = await TokenStorage.getToken();
    final result = await _handleApiRequest(
      http.post(
        Uri.parse('$baseUrl/attendance/session'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'jadwal_id': jadwalId}),
      ),
      'membuat sesi',
      'attendance',
    );

    if (result != null) {
      return attendanceSessionModel.fromJson(result);
    }
    return null;
  }

  static Future<attendanceScanModel?> scanQR(String tokenQr, double lat, double lng) async {
    final token = await TokenStorage.getToken();
    final result = await _handleApiRequest(
      http.post(
        Uri.parse('$baseUrl/attendance/scan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token_qr': tokenQr,
        }),
      ),
      'melakukan scan',
      'attendance',
    );

    if (result != null) {
      return attendanceScanModel.fromJson(result);
    }
    return null;
  }

  
}
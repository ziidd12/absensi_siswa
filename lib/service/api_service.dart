import 'dart:convert';
import 'dart:typed_data'; // Untuk Uint8List (PDF)
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/models/laporan_model.dart'; // Import model laporan kamu
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const String baseUrl = 'https://cod-active-bluejay.ngrok-free.app/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  // --------------------------------------------------------------------------
  // --- CORE REQUEST HANDLER ---
  // --------------------------------------------------------------------------

  static Future<dynamic> _handleApiRequest(
      Future<http.Response> request, String operationType, String endpoint) async {
    try {
      final response = await request.timeout(const Duration(seconds: 15));
      print("📤 DEBUG $endpoint [${response.statusCode}]: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);

        // Jika response dibungkus 'data', kita ambil isinya saja
        if (decoded is Map && decoded.containsKey('data') && endpoint != 'laporan/kehadiran/pdf') {
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

  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data dari $endpoint');
    }
  }

  

  // --------------------------------------------------------------------------
  // --- LAPORAN METHODS ---
  // --------------------------------------------------------------------------

  static Future<LaporanModel> fetchLaporanKehadiran({
    String? tingkat,
    String? jurusan,
    String? status,
    String? tahunAjaranId,
    int? page,
  }) async {
    try {
      // 1. Ambil headers (Token Otomatis)
      final headers = await _getHeaders();

      // 2. Siapkan Map untuk Query Parameters
      Map<String, String> queryParameters = {};
      
      if (tingkat != null) queryParameters['tingkat'] = tingkat;
      if (jurusan != null) queryParameters['jurusan'] = jurusan;
      if (status != null) queryParameters['status'] = status;
      if (tahunAjaranId != null) queryParameters['tahun_ajaran_id'] = tahunAjaranId;
      if (page != null) queryParameters['page'] = page.toString();

      // 3. Bangun URL dengan Query Parameters
      // Pastikan endpoint '/laporan/kehadiran' sesuai dengan Route di Laravel Anda
      final uri = Uri.parse('$baseUrl/laporan/kehadiran').replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: headers, // Menggunakan headers yang sudah berisi token
      );

      print("📤 DEBUG LAPORAN [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        // Parsing JSON ke model
        return LaporanModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat laporan. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error Fetch Laporan: $e");
      throw Exception('Error API: $e');
    }
  }

  /// Mengambil file PDF mentah
  static Future<Uint8List> downloadLaporanPdf({
    String? tingkat,
    String? jurusan,
    String? status,
    String? tahunAjaranId,
  }) async {
    // 1. Ambil header standar (yg berisi Authorization & ngrok-skip)
    final headers = await _getHeaders();
    
    // 2. TIMPA 'Accept' agar meminta PDF, bukan JSON
    headers['Accept'] = 'application/pdf';

    final Map<String, String> queryParams = {
      if (tingkat != null) 'tingkat': tingkat,
      if (jurusan != null) 'jurusan': jurusan,
      if (status != null) 'status': status,
      if (tahunAjaranId != null) 'tahun_ajaran_id': tahunAjaranId,
    };

    final uri = Uri.parse('$baseUrl/laporan/kehadiran/pdf').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      
      // Validasi magic number %PDF
      if (bytes.length > 4) {
        String header = String.fromCharCodes(bytes.take(4));
        if (header == "%PDF") return bytes; 
      }

      // Jika masuk sini, artinya Laravel masih kirim teks/JSON
      String errorRaw = utf8.decode(bytes.take(200).toList(), allowMalformed: true);
      print("❌ BUKAN PDF. ISI: $errorRaw");
      throw Exception("Respon server bukan file PDF yang valid.");
    } else {
      throw Exception('Gagal download (Status: ${response.statusCode})');
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
          // Tambahkan lat/lng jika backend kamu membutuhkannya
          'latitude': lat,
          'longitude': lng,
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

  static Future<List<dynamic>> fetchTahunAjaran() async {
    // Memanggil AcademicController@getMasterData
    final result = await get('academic/master-data'); 
    
    // Sesuaikan dengan key di backend. 
    // Jika di controller kamu namanya 'daftar_tahun_ajaran', pastikan sama.
    if (result != null && result['daftar_tahun_ajaran'] != null) {
      return result['daftar_tahun_ajaran'];
    }
    return [];
  }

  static Future<Map<String, dynamic>> fetchMasterData() async {
    // Memanggil AcademicController@getMasterData
    final result = await get('academic/master-data'); 
    
    if (result != null) {
      return result;
    }
    return {};
  }
}
import 'dart:convert';
import 'dart:typed_data'; 
import 'package:absensi_siswa/models/assessment_category_model.dart';
import 'package:absensi_siswa/models/assessment_model.dart';
import 'package:absensi_siswa/models/assessment_report_model.dart';
import 'package:http/http.dart' as http;
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/models/laporan_model.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

class ApiService {
  static const String baseUrl = 'https://cod-active-bluejay.ngrok-free.app/api';

  // --- HELPER HEADERS ---
  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', 
    };
  }

  // --- CORE REQUEST HANDLER ---
  static Future<dynamic> _handleApiRequest(
      Future<http.Response> request, String operationType, String endpoint) async {
    try {
      final response = await request.timeout(const Duration(seconds: 15));
      print("📤 DEBUG $endpoint [${response.statusCode}]: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data') && !endpoint.contains('pdf')) {
          return decoded['data'];
        }
        return decoded; 
      } else {
        throw Exception('Gagal $operationType. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error $operationType: $e');
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'), 
      headers: headers
    ).timeout(const Duration(seconds: 15));
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print("❌ API GET ERROR [$endpoint]: ${response.statusCode} - ${response.body}");
      throw Exception('Gagal mengambil data dari $endpoint (Status: ${response.statusCode})');
    }
  }

  // --- FUNGSI POST UMUM ---
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print("❌ API POST ERROR [$endpoint]: ${response.statusCode} - ${response.body}");
      throw Exception('Gagal mengirim data ke $endpoint (Status: ${response.statusCode})');
    }
  }

  // --------------------------------------------------------------------------
  // --- FITUR PENILAIAN BARU (STUDENT RATINGS) ---
  // --------------------------------------------------------------------------

  static Future<Map<String, dynamic>> simpanPenilaian(Map<String, dynamic> data) async {
    // Menembak ke Route::post('/simpan-penilaian') yang baru kita buat di Laravel
    return await post('simpan-penilaian', data);
  }

  static Future<Map<String, dynamic>> ambilPenilaianSiswa(int siswaId) async {
    // Fungsi untuk mengambil nilai yang sudah masuk ke database untuk ditampilkan di HP Siswa
    final result = await get('penilaian-siswa/$siswaId');
    return (result is Map<String, dynamic>) ? result : {};
  }

  // --------------------------------------------------------------------------
  // --- SISWA & ATTENDANCE METHODS ---
  // --------------------------------------------------------------------------

  static Future<bool> saveManualAttendance(int jadwalId, List<dynamic> daftarSiswa) async {
    final headers = await _getHeaders();
    
    final body = jsonEncode({
      'jadwal_id': jadwalId,
      'absensi': daftarSiswa.map((s) => {
        'siswa_id': s.id,
        'status': (s.status == 'Belum' || s.status == null) ? 'H' : s.status, 
      }).toList(),
    });

    final response = await http.post(
      Uri.parse('$baseUrl/attendance/manual'),
      headers: headers,
      body: body,
    ).timeout(const Duration(seconds: 15));

    print("📤 SAVE MANUAL [${response.statusCode}]: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<attendanceSessionModel?> createAttendanceSession(int jadwalId) async {
    final result = await _handleApiRequest(
      http.post(
        Uri.parse('$baseUrl/attendance/session'),
        headers: await _getHeaders(),
        body: jsonEncode({'jadwal_id': jadwalId}),
      ),
      'membuat sesi',
      'attendance/session',
    );

    if (result != null) return attendanceSessionModel.fromJson(result);
    return null;
  }

  static Future<attendanceScanModel?> scanQR(String tokenQr, double lat, double lng) async {
    final result = await _handleApiRequest(
      http.post(
        Uri.parse('$baseUrl/attendance/scan'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'token_qr': tokenQr,
          'latitude': lat,
          'longitude': lng,
        }),
      ),
      'melakukan scan',
      'attendance/scan',
    );

    if (result != null) return attendanceScanModel.fromJson(result);
    return null;
  }

  Future<http.Response> postAbsensi(String tokenQr, double lat, double long) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/attendance/scan');

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'token_qr': tokenQr,
        'lat_siswa': lat, 
        'long_siswa': long, 
      }),
    ).timeout(const Duration(seconds: 15));
  }

  // --------------------------------------------------------------------------
  // --- LAPORAN & MASTER DATA ---
  // --------------------------------------------------------------------------

  static Future<LaporanModel> fetchLaporanKehadiran({
    String? tingkat,
    String? jurusan,
    String? status,
    String? tahunAjaranId,
    int? page,
  }) async {
    final headers = await _getHeaders();
    Map<String, String> queryParameters = {};
    
    if (tingkat != null) queryParameters['tingkat'] = tingkat;
    if (jurusan != null) queryParameters['jurusan'] = jurusan;
    if (status != null) queryParameters['status'] = status;
    if (tahunAjaranId != null) queryParameters['tahun_ajaran_id'] = tahunAjaranId;
    if (page != null) queryParameters['page'] = page.toString();

    final uri = Uri.parse('$baseUrl/laporan/kehadiran').replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return LaporanModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat laporan. Status: ${response.statusCode}');
    }
  }

  static Future<Uint8List> downloadLaporanPdf({
    String? tingkat,
    String? jurusan,
    String? status,
    String? tahunAjaranId,
  }) async {
    final headers = await _getHeaders();
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
      if (bytes.length > 4 && bytes[0] == 0x25 && bytes[1] == 0x50) { 
        return bytes;
      }
      throw Exception("Respon server bukan file PDF valid.");
    } else {
      throw Exception("Gagal unduh PDF (Status: ${response.statusCode})");
    }
  }

  static Future<Map<String, dynamic>> fetchMasterData() async {
    final result = await get('academic/master-data'); 
    return (result != null) ? result : {};
  }

  // --------------------------------------------------------------------------
  // --- FITUR PENILAIAN BARU (SCORING METHODS) ---
  // --------------------------------------------------------------------------

  /// 1. Ambil Struktur Form (Kategori & Pertanyaan)
  /// Endpoint: GET /api/scoring/form-structure
  static Future<List<AssessmentCategory>> getAssessmentForm({String type = 'student'}) async {
    try {
      final result = await get('scoring/form-structure?type=$type');
      if (result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        return data.map((e) => AssessmentCategory.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getAssessmentForm: $e');
      return [];
    }
  }

  /// 2. Ambil Daftar Siswa yang akan dinilai
  /// Endpoint: GET /api/scoring/students-to-assess
  static Future<List<dynamic>> getStudentsToAssess(dynamic tahunAjaranId) async {
    try {
      // 1. Panggil API dengan query parameter
      final result = await get('scoring/students-to-assess?tahun_ajaran_id=$tahunAjaranId');
      
      print("DEBUG API RESULT: $result"); // Untuk memastikan data muncul di console

      // 2. Ambil isi dari key 'data' karena Laravel membungkusnya
      if (result is Map && result.containsKey('data')) {
        return result['data'] as List<dynamic>;
      }
      
      // 3. Fallback jika ternyata Laravel return list langsung
      if (result is List) return result;
      
      return [];
    } catch (e) {
      print('❌ Error getStudentsToAssess: $e');
      return [];
    }
  }

  /// 3. Submit Penilaian (Store)
  /// Endpoint: POST /api/scoring/submit
  /// Data dikirim sesuai format Assessment.toJson()
  static Future<Map<String, dynamic>> submitAssessment(Assessment assessment) async {
    try {
      // Menggunakan data.toJson() yang sudah kita buat di model Assessment
      return await post('scoring/submit', assessment.toJson());
    } catch (e) {
      print('❌ Error submitAssessment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// 4. Laporan Performa (Radar Chart & History)
  /// Endpoint: GET /api/scoring/performance-radar
  static Future<StudentPerformanceReport?> getPerformanceRadar({int? studentId, int? tahunAjaranId}) async {
    try {
      String params = "";
      if (studentId != null) params += "student_id=$studentId";
      if (tahunAjaranId != null) params += "${params.isEmpty ? '' : '&'}tahun_ajaran_id=$tahunAjaranId";
      
      final result = await get('scoring/performance-radar${params.isEmpty ? '' : '?$params'}');
      
      if (result['status'] == 'success') {
        return StudentPerformanceReport.fromJson(result);
      }
      return null;
    } catch (e) {
      print('❌ Error getPerformanceRadar: $e');
      return null;
    }
  }

  /// 5. Ringkasan Nilai Siswa
  /// Endpoint: GET /api/scoring/summary-student
  static Future<List<AssessmentReportData>> getSummaryStudent() async {
    try {
      final result = await get('scoring/summary-student');
      // Karena student() di controller mengembalikan response()->json($data) langsung
      if (result is List) {
        return result.map((e) => AssessmentReportData.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getSummaryStudent: $e');
      return [];
    }
  }

  /// 6. Statistik Progres Guru
  /// Endpoint: GET /api/scoring/teacher-stats
  static Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final result = await get('scoring/teacher-stats');
      return result is Map<String, dynamic> ? result : {};
    } catch (e) {
      print('❌ Error getTeacherStats: $e');
      return {};
    }
  }
}
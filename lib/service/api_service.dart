import 'dart:convert';
import 'dart:typed_data'; 
import 'package:absensi_siswa/models/teacher_dashboard_model.dart';
import 'package:http/http.dart' as http;
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/models/laporan_model.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

class ApiService {
  static const String baseUrl = 'https://calculous-unsculptured-ngan.ngrok-free.dev/api';

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
  // --- FITUR PENILAIAN LAMA (Bisa kamu hapus jika sudah fix pakai yang baru) ---
  // --------------------------------------------------------------------------

  // static Future<List<dynamic>> getAssessmentCategories() async {
  //   final result = await get('assessment/categories');
  //   if (result is Map && result.containsKey('data')) {
  //     return result['data'];
  //   }
  //   return result is List ? result : [];
  // }

  // static Future<bool> submitAssessment({
  //   required int siswaId,
  //   required List<Map<String, dynamic>> scores,
  //   String? notes,
  // }) async {
  //   final body = {
  //     'siswa_id': siswaId,
  //     'scores': scores,
  //     'notes': notes,
  //     'period': 'Semester Ganjil 2026',
  //   };

  //   try {
  //     await post('assessment/store', body);
  //     return true;
  //   } catch (e) {
  //     print("Error submit assessment: $e");
  //     return false;
  //   }
  // }

  // ==================== ASSESSMENT API METHODS ====================

  /// Mendapatkan daftar kategori penilaian
  static Future<List<AssessmentCategoryModel>> getAssessmentCategories() async {
    try {
      final response = await get('assessment/categories');
      
      if (response is Map && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        return data.map((e) => AssessmentCategoryModel.fromJson(e)).toList();
      } else if (response is List) {
        return response.map((e) => AssessmentCategoryModel.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error getAssessmentCategories: $e');
      return [];
    }
  }

  /// Menyimpan penilaian baru (untuk guru)
  static Future<Map<String, dynamic>> submitAssessment({
    required int siswaId,
    required int categoryId,
    required double score,
    String? period,
    String? generalNotes,
  }) async {
    try {
      final data = {
        'siswa_id': siswaId,
        'category_id': categoryId,
        'score': score,
        'period': period ?? 'Ganjil 2026',
        'general_notes': generalNotes,
      };
      
      return await post('assessment/store', data);
    } catch (e) {
      print('❌ Error submitAssessment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Menyimpan penilaian dengan multiple kategori
  static Future<Map<String, dynamic>> submitPenilaianGuru({
    required int siswaId,
    required Map<int, double> scores,
    String? catatan,
  }) async {
    try {
      List<Map<String, dynamic>> scoresList = scores.entries.map((e) {
        return {
          'category_id': e.key,
          'score': e.value * 20,
        };
      }).toList();

      final data = {
        'siswa_id': siswaId,
        'scores': scoresList,
        'general_notes': catatan,
        'period': 'Ganjil 2026',
      };
      
      return await post('assessment/store-batch', data);
    } catch (e) {
      print('❌ Error submitPenilaianGuru: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Mendapatkan data dashboard untuk guru
  static Future<Map<String, dynamic>> getTeacherDashboard() async {
    try {
      return await get('teacher/dashboard');
    } catch (e) {
      print('❌ Error getTeacherDashboard: $e');
      return {};
    }
  }

  /// Mendapatkan performa siswa
  static Future<StudentPerformanceModel?> getStudentPerformance({
    int? studentId,
  }) async {
    try {
      String endpoint = 'assessment/student-performance';
      if (studentId != null) {
        endpoint += '?student_id=$studentId';
      }
      
      final response = await get(endpoint);
      
      if (response is Map<String, dynamic>) {
        return StudentPerformanceModel.fromJson(response);
      }
      
      return null;
    } catch (e) {
      print('❌ Error getStudentPerformance: $e');
      return null;
    }
  }

  /// Mendapatkan progress guru
  static Future<TeacherProgressModel?> getTeacherProgress() async {
    try {
      final response = await get('assessment/teacher-progress');
      
      if (response is Map<String, dynamic>) {
        return TeacherProgressModel.fromJson(response);
      }
      
      return null;
    } catch (e) {
      print('❌ Error getTeacherProgress: $e');
      return null;
    }
  }

  /// Mendapatkan statistik kelas
  static Future<ClassStatisticsModel?> getClassStatistics(int kelasId) async {
    try {
      final response = await get('assessment/class/$kelasId/statistics');
      
      if (response is Map<String, dynamic>) {
        return ClassStatisticsModel.fromJson(response);
      }
      
      return null;
    } catch (e) {
      print('❌ Error getClassStatistics: $e');
      return null;
    }
  }

  /// Mendapatkan kategori untuk form penilaian
  static Future<List<KategoriPenilaian>> getKategoriPenilaian() async {
    try {
      final response = await get('assessment/categories');
      
      if (response is Map && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        return data.map((e) => KategoriPenilaian.fromJson(e)).toList();
      } else if (response is List) {
        return response.map((e) => KategoriPenilaian.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error getKategoriPenilaian: $e');
      return [];
    }
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:absensi_siswa/models/assessment_category_model.dart';
import 'package:absensi_siswa/models/assessment_model.dart';
import 'package:absensi_siswa/models/assessment_report_model.dart';
import 'package:absensi_siswa/models/jadwal_model.dart';
import 'package:absensi_siswa/models/marketplace_model.dart';
import 'package:absensi_siswa/models/poin_history_model.dart';
import 'package:absensi_siswa/models/user_token_model.dart';
import 'package:http/http.dart' as http;
import 'package:absensi_siswa/models/attendance_scan_model.dart';
import 'package:absensi_siswa/models/attendance_session_model.dart';
import 'package:absensi_siswa/models/laporan_model.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

// --- MODEL STORE ITEM (DITAMBAHKAN BIAR BISA DIPAKAI DI SERVICE) ---
class StoreItem {
  final int id;
  final String namaItem;
  final int hargaPoin;
  final String icon;
  final String warna;
  final int stok;

  StoreItem({
    required this.id,
    required this.namaItem,
    required this.hargaPoin,
    required this.icon,
    required this.warna,
    required this.stok,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] ?? 0,
      namaItem: json['nama_item'] ?? '',
      hargaPoin: json['harga_poin'] ?? 0,
      icon: json['icon'] ?? 'fastfood',
      warna: json['warna'] ?? 'orange',
      stok: json['stok'] ?? 0,
    );
  }
}

class ApiService {
  // Ganti https menjadi http
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
    Future<http.Response> request,
    String operationType,
    String endpoint,
  ) async {
    try {
      final response = await request.timeout(const Duration(seconds: 15));
      print("📤 DEBUG $endpoint [${response.statusCode}]: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        final decoded = jsonDecode(response.body);
        if (decoded is Map &&
            decoded.containsKey('data') &&
            !endpoint.contains('pdf')) {
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
    print("🚀 GET: $baseUrl/$endpoint");

    final response = await http
        .get(Uri.parse('$baseUrl/$endpoint'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print("❌ GET ERROR [$endpoint]: ${response.statusCode} - ${response.body}");
      throw Exception('Gagal memuat data (Status: ${response.statusCode})');
    }
  }

  // --- CORE POST REQUEST ---
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    print("🚀 POST: $baseUrl/$endpoint | Body: $data");

    final response = await http
        .post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: headers,
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print("❌ POST ERROR [$endpoint]: ${response.statusCode} - ${response.body}");
      // Kembalikan body agar pesan error dari Laravel (misal: "Poin Kurang") bisa dibaca
      return jsonDecode(response.body);
    }
  }

  // --------------------------------------------------------------------------
  // --- FITUR PENILAIAN BARU (STUDENT RATINGS) ---
  // --------------------------------------------------------------------------

  static Future<Map<String, dynamic>> simpanPenilaian(
    Map<String, dynamic> data,
  ) async {
    // Menembak ke Route::post('/simpan-penilaian') yang baru kita buat di Laravel
    return await post('scoring/submit', data);
  }

  static Future<Map<String, dynamic>> ambilPenilaianSiswa() async {
    try {
      // Memanggil endpoint scoring/summary-student
      final result = await get('scoring/summary-student');

      // Jika Laravel mengembalikan List dalam key 'data', kita ambil index pertama
      if (result['data'] is List && result['data'].isNotEmpty) {
        return result['data'][0];
      }
      return result['data'] ?? {};
    } catch (e) {
      print('❌ Error ambilPenilaianSiswa: $e');
      return {};
    }
  }
// --------------------------------------------------------------------------
  // --- SISWA & ATTENDANCE METHODS (TANPA LOKASI) ---
  // --------------------------------------------------------------------------

  static Future<AttendanceSessionModel?> createAttendanceSession(int jadwalId) async {
    try {
      final result = await post('attendance/session', {'jadwal_id': jadwalId});
      return AttendanceSessionModel.fromJson(result);
    } catch (e) {
      print('❌ Error createAttendanceSession: $e');
      return null;
    }
  }

  static Future<AttendanceScanModel?> scanQR(String tokenQr) async {
    try {
      // Hanya mengirimkan token_qr ke server
      final result = await post('attendance/scan', {
        'token_qr': tokenQr,
      });
      return AttendanceScanModel.fromJson(result);
    } catch (e) {
      print('❌ Error scanQR: $e');
      return null;
    }
  }

  // Fungsi cadangan jika masih menggunakan instance method (Tanpa Lat/Long)
  Future<Map<String, dynamic>> postAbsensi(String tokenQr) async {
    return await ApiService.post('attendance/scan', {
      'token_qr': tokenQr,
    });
  }

  static Future<bool> saveManualAttendance(int jadwalId, List<dynamic> daftarSiswa) async {
    try {
      final result = await post('attendance/manual', {
        'jadwal_id': jadwalId,
        'absensi': daftarSiswa.map((s) => {
          'siswa_id': s.id,
          'status': (s.status == 'Belum' || s.status == null) ? 'H' : s.status,
        }).toList(),
      });
      return result['status'] == 'success';
    } catch (e) {
      print("❌ SAVE MANUAL ERROR: $e");
      return false;
    }
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
    if (tahunAjaranId != null)
      queryParameters['tahun_ajaran_id'] = tahunAjaranId;
    if (page != null) queryParameters['page'] = page.toString();

    final uri = Uri.parse(
      '$baseUrl/laporan/kehadiran',
    ).replace(queryParameters: queryParameters);
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

    final uri = Uri.parse(
      '$baseUrl/laporan/kehadiran/pdf',
    ).replace(queryParameters: queryParams);
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
  static Future<List<AssessmentCategory>> getAssessmentForm({
    String type = 'student',
  }) async {
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
  static Future<List<dynamic>> getStudentsToAssess(
    dynamic tahunAjaranId,
  ) async {
    try {
      final result = await get(
        'scoring/students-to-assess?tahun_ajaran_id=$tahunAjaranId',
      );
      if (result is Map && result.containsKey('data')) {
        return result['data'] as List<dynamic>;
      }
      if (result is List) return result;
      return [];
    } catch (e) {
      print('❌ Error getStudentsToAssess: $e');
      return [];
    }
  }

  /// 3. Submit Penilaian (Store)
  static Future<Map<String, dynamic>> submitAssessment(
    Assessment assessment,
  ) async {
    try {
      return await post('scoring/submit', assessment.toJson());
    } catch (e) {
      print('❌ Error submitAssessment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// 4. Laporan Performa (Radar Chart & History)
  static Future<StudentPerformanceReport?> getPerformanceRadar({
    int? studentId,
    int? tahunAjaranId,
  }) async {
    try {
      String params = "";
      if (studentId != null) params += "student_id=$studentId";
      if (tahunAjaranId != null)
        params += "${params.isEmpty ? '' : '&'}tahun_ajaran_id=$tahunAjaranId";

      final result = await get(
        'scoring/performance-radar${params.isEmpty ? '' : '?$params'}',
      );

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
  static Future<List<AssessmentReportData>> getSummaryStudent() async {
    try {
      final result = await get('scoring/summary-student');
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
  static Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final result = await get('scoring/teacher-stats');
      return result is Map<String, dynamic> ? result : {};
    } catch (e) {
      print('❌ Error getTeacherStats: $e');
      return {};
    }
  }

  // --- JADWAL METHODS ---
  // --- JADWAL METHODS ---
  static Future<List<JadwalModel>> getJadwalHariIni() async {
    try {
      final result = await get('jadwal-hari-ini');

      List<dynamic> data;
      if (result is Map && result.containsKey('data')) {
        data = result['data'];
      } else if (result is List) {
        data = result;
      } else {
        return [];
      }

      return data.map((e) => JadwalModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getJadwalHariIni: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // --- FITUR GAMIFIKASI (DOMPET INTEGRITAS) ---
  // --------------------------------------------------------------------------

  /// TAB 2 & HERO: Ambil Saldo & List Item Marketplace
  static Future<MarketplaceResponse?> fetchMarketplace() async {
    try {
      final result = await get('gamifikasi/marketplace');
      return MarketplaceResponse.fromJson(result);
    } catch (e) {
      print('❌ Error fetchMarketplace: $e');
      return null;
    }
  }

  /// TAB 1: Riwayat Mutasi Poin (Ledger)
  static Future<List<PointLedger>> fetchPointHistory() async {
    try {
      final result = await get('gamifikasi/history');
      if (result['status'] == 'success') {
        return (result['data'] as List)
            .map((e) => PointLedger.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetchPointHistory: $e');
      return [];
    }
  }

  /// TAB 3: My Inventory (Token yang dimiliki)
  static Future<List<UserToken>> fetchUserInventory() async {
    try {
      final result = await get('gamifikasi/inventory');
      if (result['status'] == 'success') {
        return (result['data'] as List)
            .map((e) => UserToken.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetchUserInventory: $e');
      return [];
    }
  }

  /// ACTION: Tukar Poin (Redeem)
  static Future<Map<String, dynamic>> postRedeem(int itemId) async {
    try {
      return await post('gamifikasi/redeem', {'item_id': itemId});
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal terhubung ke server'};
    }
  }
}

import 'dart:convert';
import 'package:absensi_siswa/device_helper.dart';
import 'package:absensi_siswa/models/login_model.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://cod-active-bluejay.ngrok-free.app/api';

  Future<bool> verifyToken(String token) async {
    final url = Uri.parse('$_baseUrl/profile'); 
    
    try {
        final response = await http.get(
            url,
            headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'ngrok-skip-browser-warning': 'true', 
            },
        ).timeout(const Duration(seconds: 15));

        return response.statusCode == 200;
    } catch (e) {
        print('❌ Error saat verifikasi token: $e');
        return false;
    }
  }

  Future<loginModel> login(String serial, String password) async { 
    final url = Uri.parse('$_baseUrl/login');

    try {
      String autoDeviceId;
      try {
        // Cek Device ID, berikan fallback string jika gagal (terutama di Web)
        autoDeviceId = await DeviceHelper.getDeviceId();
      } catch (e) {
        autoDeviceId = 'web_device_${DateTime.now().millisecondsSinceEpoch}';
      }

      print('🚀 Melakukan login untuk: $serial');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true', 
        },
        body: jsonEncode({
          'email': serial,        // ⬅️ UBAH DARI 'serial_number' MENJADI 'email'
          'password': password,
          'device_id': autoDeviceId, 
        }),
      ).timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return loginModel.fromJson(responseBody);
      } else {
        // Menampilkan pesan error spesifik dari server jika ada
        throw Exception(responseBody['message'] ?? 'Gagal login: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di AuthService Login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final token = await TokenStorage.getToken();
    
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        print('Warning: Gagal memanggil API logout ke server.');
      }
    }
    await TokenStorage.clearAll();
  }
}
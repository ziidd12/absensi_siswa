import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/auth_service.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:absensi_siswa/models/login_model.dart'; // Pastikan path ini benar

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userName;
  String? get userName => _userName;
  
  String? _userSerial; 
  String? get userSerial => _userSerial;
  
  String? _userRole; 
  String? get userRole => _userRole;

  int? _userId;
  int? get userId => _userId;

  String? _token;
  String? get token => _token;

  AuthViewModel() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _token = await TokenStorage.getToken();

    if (_token != null && _token!.isNotEmpty) {
      print('⏳ Token lokal ditemukan. Memvalidasi ke server...');
      
      final isTokenValid = await _authService.verifyToken(_token!);
      
      if (isTokenValid) {
        _userId = await TokenStorage.getUserId();
        _userName = await TokenStorage.getUserName();
        _userSerial = await TokenStorage.getUserSerialNumber();
        _userRole = await TokenStorage.getUserRole();
        _isLoggedIn = true;
        print('✅ Sesi valid untuk user: $_userName (Role: $_userRole)');
      } else {
        print('⚠️ Token tidak valid atau expired. Sesi dihapus.');
        await TokenStorage.clearAll();
        _resetLocalState();
      }
    } else {
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String serial, String password) async { 
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🚀 Memulai proses login untuk: $serial');
      // Memanggil AuthService yang mengembalikan loginModel
      final loginModel response = await _authService.login(serial, password);
      
      // Akses data sesuai struktur loginModel baru
      final userData = response.data?.user; 
      final userToken = response.data?.token;

      if (userData == null || userToken == null) {
        throw Exception("Data user atau token tidak ditemukan dari respon server");
      }

      String displayName = userData.name ?? "User";

      print('📦 Menyimpan session untuk: $displayName dengan Role: ${userData.role}');

      // Simpan ke SharedPreferences melalui TokenStorage
      await TokenStorage.saveUserSession(
        token: userToken,
        id: userData.id!,
        name: displayName,
        // Karena di model User tidak ada serial_number, kita gunakan input 'serial' dari user
        serialNumber: serial, 
        role: userData.role ?? 'siswa',
      ); 

      // Update state internal
      _isLoggedIn = true;
      _token = userToken;
      _userId = userData.id;
      _userName = displayName;
      _userSerial = serial; 
      _userRole = userData.role; 

      print('✅ Login Berhasil. Status: $_isLoggedIn, Role: $_userRole');

      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      print('❌ Login Gagal di ViewModel: $e');
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout(); 
      print("🔴 Pengguna berhasil logout API.");
    } catch (e) {
      print("⚠️ Gagal logout API, tapi sesi lokal tetap dihapus: $e");
    } finally {
      await TokenStorage.clearAll();
      _resetLocalState();
      _isLoading = false;
      notifyListeners();
      
      // Navigasi ke halaman login dan hapus semua stack
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _resetLocalState() {
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    _userName = null;
    _userSerial = null;
    _userRole = null;
    _errorMessage = null;
  }
}
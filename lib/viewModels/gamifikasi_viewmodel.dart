import 'package:absensi_siswa/models/poin_history_model.dart';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/models/marketplace_model.dart';
import 'package:absensi_siswa/models/user_token_model.dart';
import 'package:absensi_siswa/service/api_service.dart';

class GamifikasiViewModel extends ChangeNotifier {
  // --- STATE VARIABLES ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Data Saldo & Marketplace (Tab 2)
  int _balance = 0;
  int get balance => _balance;

  List<FlexibilityItem> _marketplaceItems = [];
  List<FlexibilityItem> get marketplaceItems => _marketplaceItems;

  // Data Riwayat Mutasi (Tab 1)
  List<PointLedger> _pointHistory = [];
  List<PointLedger> get pointHistory => _pointHistory;

  // Data Inventory Token (Tab 3)
  List<UserToken> _inventory = [];
  List<UserToken> get inventory => _inventory;

  // --- LOGIKA LEVEL USER (Sesuai Panduan) ---
  String get userLevel {
    if (_balance >= 500) return "Disiplin Elite";
    if (_balance >= 200) return "Teladan";
    if (_balance >= 100) return "Warga Patuh";
    return "Pemula";
  }

  // --- FUNGSI UTAMA ---

  /// Mengambil data Saldo dan Marketplace sekaligus
  Future<void> fetchMarketplaceData() async {
    _setLoading(true);
    try {
      final response = await ApiService.fetchMarketplace();
      if (response != null && response.status == 'success') {
        _balance = response.data.balance;
        _marketplaceItems = response.data.items;
        _errorMessage = null;
      } else {
        _errorMessage = "Gagal memuat data marketplace";
      }
    } catch (e) {
      _errorMessage = "Koneksi bermasalah: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil Riwayat Mutasi Poin (Tab 1)
  Future<void> fetchPointHistory() async {
    _setLoading(true);
    try {
      _pointHistory = await ApiService.fetchPointHistory();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat riwayat poin";
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil Inventory Token (Tab 3)
  Future<void> fetchInventory() async {
    _setLoading(true);
    try {
      _inventory = await ApiService.fetchUserInventory();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat inventory";
    } finally {
      _setLoading(false);
    }
  }

  /// Proses Tukar Poin (Redeem)
  Future<bool> redeemToken(int itemId) async {
    _setLoading(true);
    try {
      final result = await ApiService.postRedeem(itemId);
      
      if (result['status'] == 'success') {
        _errorMessage = result['message'];
        
        // REFRESH SEMUA DATA AGAR SINCRON
        await fetchMarketplaceData(); // Update Saldo
        await fetchInventory();       // Update Inventory
        await fetchPointHistory();   // <--- TAMBAHKAN INI AGAR RIWAYAT MUNCUL
        
        return true;
      } else {
        _errorMessage = result['message'] ?? "Gagal menukarkan poin";
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan sistem";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inisialisasi awal saat Dashboard dibuka
  Future<void> initDashboard() async {
    // Jalankan semua fetch secara paralel agar cepat
    await Future.wait([
      fetchMarketplaceData(),
      fetchPointHistory(),
      fetchInventory(),
    ]);
  }

  // --- HELPER ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Membersihkan pesan error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
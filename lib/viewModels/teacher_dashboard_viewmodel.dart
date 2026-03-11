import 'package:absensi_siswa/models/assessment_model.dart';
import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class TeacherDashboardViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  TeacherDashboardModel? _dashboardData;
  List<SiswaPenilaian> _filteredBelumDinilai = [];
  List<SiswaPenilaian> _filteredSudahDinilai = [];
  String _searchQuery = '';
  String _selectedFilter = 'semua';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TeacherDashboardModel? get dashboardData => _dashboardData;
  List<SiswaPenilaian> get filteredBelumDinilai => _filteredBelumDinilai;
  List<SiswaPenilaian> get filteredSudahDinilai => _filteredSudahDinilai;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  double get progress => _dashboardData?.progress ?? 0;
  int get totalSiswa => _dashboardData?.totalSiswa ?? 0;
  int get dinilaiCount => _dashboardData?.dinilaiCount ?? 0;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final response = await ApiService.getTeacherDashboard();
      
      if (response.isNotEmpty) {
        _dashboardData = TeacherDashboardModel.fromJson(response);
        _applyFilter();
      } else {
        _errorMessage = 'Gagal memuat data dashboard';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    if (_dashboardData == null) return;

    List<SiswaPenilaian> filterBySearch(List<SiswaPenilaian> list) {
      if (_searchQuery.isEmpty) return list;
      
      return list.where((siswa) =>
        siswa.nama.toLowerCase().contains(_searchQuery) ||
        siswa.nis.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    switch (_selectedFilter) {
      case 'belum':
        _filteredBelumDinilai = filterBySearch(_dashboardData!.belumDinilai);
        _filteredSudahDinilai = [];
        break;
      case 'sudah':
        _filteredBelumDinilai = [];
        _filteredSudahDinilai = filterBySearch(_dashboardData!.sudahDinilai);
        break;
      default:
        _filteredBelumDinilai = filterBySearch(_dashboardData!.belumDinilai);
        _filteredSudahDinilai = filterBySearch(_dashboardData!.sudahDinilai);
    }
    
    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadDashboard();
  }
}
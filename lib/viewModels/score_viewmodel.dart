import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class ScoreViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _dataRating;
  Map<String, dynamic>? get dataRating => _dataRating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Getter untuk memproses angka langsung di ViewModel (UI terima bersih)
  double get disiplin => _parseScore(_dataRating?['kedisiplinan']);
  double get tim => _parseScore(_dataRating?['kerja_sama']);
  double get tanggungJawab => _parseScore(_dataRating?['tanggung_jawab']);
  double get inisiatif => _parseScore(_dataRating?['inisiatif']);
  String get catatan => _dataRating?['catatan'] ?? "Belum ada catatan pembimbing.";

  double get totalAvg {
    if (_dataRating == null) return 0;
    return (disiplin + tim + tanggungJawab + inisiatif) / 4;
  }

  double _parseScore(dynamic value) {
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  Future<void> fetchMyScores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('scoring/summary-student');
      
      // LOGIKA PERBAIKAN:
      if (response is List) {
        // Jika response langsung berupa List: [ {...} ]
        if (response.isNotEmpty) {
          _dataRating = response[0];
        }
      } else if (response is Map) {
        // Jika response berupa Map: {"data": [...]} atau {"data": {...}}
        final data = response['data'];
        if (data is List && data.isNotEmpty) {
          _dataRating = data[0];
        } else if (data is Map<String, dynamic>) {
          _dataRating = data;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("❌ Error fetch score: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
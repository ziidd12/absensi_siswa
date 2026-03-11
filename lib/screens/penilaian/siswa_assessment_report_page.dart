import 'package:absensi_siswa/models/assessment_report_model.dart';
import 'package:absensi_siswa/viewmodels/assessment_viewmodel.dart';
import 'package:absensi_siswa/viewmodels/auth_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SiswaAssessmentReportPage extends StatefulWidget {
  const SiswaAssessmentReportPage({super.key});

  @override
  State<SiswaAssessmentReportPage> createState() => _SiswaAssessmentReportPageState();
}

class _SiswaAssessmentReportPageState extends State<SiswaAssessmentReportPage> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  static const Color bgLight = Color(0xFFF6F8FC);

  @override
  void initState() {
    super.initState();
    // Inisialisasi format lokal Indonesia agar nama bulan muncul dalam Bahasa Indonesia
    initializeDateFormatting('id_ID', null);
    _loadMyReport();
  }

  Future<void> _loadMyReport() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final userId = authVM.userId;
      
      if (userId != null) {
        context.read<AssessmentViewModel>().fetchStudentPerformance(
          studentId: userId,
          tahunAjaranId: 1, 
        );
      }
    });
  }

  // Fungsi Helper untuk memformat tanggal agar aman dari error "Tidak Valid"
  String formatTanggal(dynamic dateData) {
    if (dateData == null) return "-";
    try {
      DateTime dateTime;
      if (dateData is DateTime) {
        dateTime = dateData;
      } else {
        dateTime = DateTime.parse(dateData.toString());
      }
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return "Format Tanggal Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchVM = context.watch<AssessmentViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final double totalScore = watchVM.totalScore;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Capaian Karakter Saya", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: watchVM.isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryBlue))
        : RefreshIndicator(
            onRefresh: _loadMyReport,
            color: primaryBlue,
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSiswaHeader(authVM.userName, authVM.userSerial),
                    const SizedBox(height: 25),
                    
                    _buildTotalScoreSection(totalScore),
                    const SizedBox(height: 30),
                    
                    const Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 20, color: primaryBlue),
                        SizedBox(width: 8),
                        Text("GRAFIK PERKEMBANGAN", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.1)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildRadarChartCard(watchVM.reportData),
                    
                    const SizedBox(height: 30),
                    const Text("Rincian Nilai", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    _buildMinimalistScoreList(watchVM.reportData),
                    
                    const SizedBox(height: 30),
                    const Text("Riwayat Catatan Guru", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    // Pastikan model PerformanceReport memiliki history yang berisi List<Assessment>
                    _buildModernTimeline(watchVM.performanceReport?.history ?? [])
                  ],
                ),
              ),
          ),
    );
  }

  Widget _buildSiswaHeader(String? name, String? nis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(name != null && name.isNotEmpty ? name[0] : "?", 
              style: const TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halo, ${name ?? 'Siswa'}", 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1A1A1A))),
                Text("NIS: ${nis ?? '-'}", 
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreSection(double score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, Color(0xFF5389FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SKOR RATA-RATA", 
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 5),
              Text(
                score >= 8.5 ? "Sangat Terpuji" : score >= 7.0 ? "Sudah Baik" : "Tingkatkan Lagi",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              score.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChartCard(List<AssessmentReportData> data) {
    if (data.isEmpty) return const SizedBox();
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          getTitle: (index, angle) => RadarChartTitle(text: data[index].categoryName, angle: angle),
          titleTextStyle: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
          dataSets: [
            RadarDataSet(
              fillColor: primaryBlue.withOpacity(0.1),
              borderColor: primaryBlue,
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: data.map((e) => RadarEntry(value: e.averageScore.toDouble())).toList(),
            ),
          ],
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          gridBorderData: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
    );
  }

  Widget _buildMinimalistScoreList(List<AssessmentReportData> data) {
    return Column(
      children: data.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: bgLight,
              child: Icon(Icons.check_circle_outline_rounded, color: primaryBlue, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Text(item.averageScore.toStringAsFixed(1), 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryBlue)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildModernTimeline(List history) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text("Belum ada riwayat penilaian", style: TextStyle(color: Colors.grey))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        
        // Menggunakan helper formatTanggal yang sudah dibuat di atas
        // Pastikan 'assessmentDate' adalah nama field di model Assessment kamu
        String formattedDate = formatTanggal(item.assessmentDate);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                ),
                Container(width: 2, height: 60, color: primaryBlue.withOpacity(0.1)),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.03)),
                    ),
                    // Menggunakan generalNotes sesuai class Assessment yang kamu buat
                    child: Text(item.generalNotes ?? 'Tidak ada catatan tambahan',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
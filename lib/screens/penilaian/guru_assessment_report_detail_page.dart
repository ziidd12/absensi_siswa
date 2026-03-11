import 'package:absensi_siswa/models/assessment_report_model.dart';
import 'package:absensi_siswa/viewmodels/assessment_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GuruAssessmentReportDetailPage extends StatefulWidget {
  final dynamic siswa;
  const GuruAssessmentReportDetailPage({super.key, required this.siswa});

  @override
  State<GuruAssessmentReportDetailPage> createState() => _GuruAssessmentReportDetailPageState();
}

class _GuruAssessmentReportDetailPageState extends State<GuruAssessmentReportDetailPage> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  static const Color bgLight = Color(0xFFF6F8FC);

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentViewModel>().fetchStudentPerformance(
        studentId: widget.siswa['id'],
        tahunAjaranId: 1, 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchVM = context.watch<AssessmentViewModel>();
    final double totalScore = watchVM.totalScore;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Analisis Karakter", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: watchVM.isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryBlue))
        : RefreshIndicator(
            onRefresh: _loadReport,
            color: primaryBlue,
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernHeader(),
                    const SizedBox(height: 25),
                    
                    _buildTotalScoreSection(totalScore),
                    const SizedBox(height: 30),
                    
                    const Row(
                      children: [
                        Icon(Icons.radar_rounded, size: 20, color: primaryBlue),
                        SizedBox(width: 8),
                        Text("SEBARAN KARAKTER", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.1)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildRadarChartCard(watchVM.reportData),
                    
                    const SizedBox(height: 30),
                    const Text("Rincian Kompetensi", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    _buildMinimalistScoreList(watchVM.reportData),
                    
                    const SizedBox(height: 30),
                    const Text("Catatan Evaluasi", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    _buildModernTimeline(),
                  ],
                ),
              ),
          ),
    );
  }

  // BENTUK BARU: Header tanpa lingkaran, menggunakan gaya kotak inisial
  Widget _buildModernHeader() {
    final String nis = widget.siswa['siswa']?['NIS']?.toString() ?? 
                       widget.siswa['NIS']?.toString() ?? "-";

    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primaryBlue.withOpacity(0.1), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(widget.siswa['name']?[0] ?? "?", 
            style: const TextStyle(color: primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.siswa['name'] ?? "-", 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              Text("NIS: $nis", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  // BENTUK BARU: Card Kumulatif dengan gaya "Double Container"
  Widget _buildTotalScoreSection(double score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("INDEKS TOTAL", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  score >= 4.0 ? "Karakter Sangat Baik" : score >= 3.0 ? "Karakter Baik" : "Perlu Bimbingan",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              score.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  // BENTUK BARU: Radar Chart tanpa bayangan, menggunakan border tipis
  Widget _buildRadarChartCard(List<AssessmentReportData> data) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("Data belum tersedia", style: TextStyle(color: Colors.grey))),
      );
    }

    List<AssessmentReportData> displayData = List.from(data);
    if (displayData.length < 3) {
      while (displayData.length < 3) {
        displayData.add(AssessmentReportData(categoryName: "", averageScore: 0));
      }
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          getTitle: (index, angle) => RadarChartTitle(text: displayData[index].categoryName, angle: angle),
          titleTextStyle: const TextStyle(color: primaryBlue, fontSize: 9, fontWeight: FontWeight.bold),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              entryRadius: 0,
              dataEntries: displayData.map((e) => const RadarEntry(value: 5)).toList(),
            ),
            RadarDataSet(
              fillColor: primaryBlue.withOpacity(0.15),
              borderColor: primaryBlue,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: displayData.map((e) => RadarEntry(value: e.averageScore.toDouble())).toList(),
            ),
          ],
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          gridBorderData: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
    );
  }

  // BENTUK BARU: List Item yang lebih Flat
  Widget _buildMinimalistScoreList(List<AssessmentReportData> data) {
    return Column(
      children: data.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
            ),
            const SizedBox(width: 12),
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

  // BENTUK BARU: Timeline yang lebih modern dan ramping
  Widget _buildModernTimeline() {
    final List history = widget.siswa['assessments_received'] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final String rawDate = item['assessment_date'] ?? DateTime.now().toString();
        
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Container(width: 2, color: primaryBlue.withOpacity(0.1)),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.parse(rawDate)), 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13)
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['general_notes'] ?? "Tidak ada catatan.", 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5)
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
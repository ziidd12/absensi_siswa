import 'package:absensi_siswa/screens/penilaian/form_penilaian_screen.dart';
import 'package:absensi_siswa/screens/penilaian/guru_assessment_report_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/viewmodels/assessment_viewmodel.dart';

class PilihSiswaPenilaianPage extends StatefulWidget {
  const PilihSiswaPenilaianPage({super.key});

  @override
  State<PilihSiswaPenilaianPage> createState() => _PilihSiswaPenilaianPageState();
}

class _PilihSiswaPenilaianPageState extends State<PilihSiswaPenilaianPage> {
  // Samakan warna dengan Homepage Guru
  static const Color primaryBlue = Color(0xFF1E5EFF);
  static const Color accentBlue = Color(0xFF2A7CFF);

  Future<void> _loadData() async {
    final vm = context.read<AssessmentViewModel>();
    await vm.fetchStudentsToAssess(1);
    await vm.fetchTeacherProgress();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          "Evaluasi Sikap",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: primaryBlue,
        child: vm.isLoading && vm.students.isEmpty
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProgressHeaderCard(vm),
                  const SizedBox(height: 24),
                  const Text(
                    "Daftar Siswa",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  if (vm.students.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.students.length,
                      itemBuilder: (context, index) {
                        final student = vm.students[index];
                        return _buildStudentTile(context, student);
                      },
                    ),
                ],
              ),
      ),
    );
  }

  // Header Card dengan style Blue Gradient seperti di Homepage Guru
  Widget _buildProgressHeaderCard(AssessmentViewModel vm) {
    final int total = int.tryParse(vm.teacherProgress['total']?.toString() ?? '0') ?? 0;
    final int done = int.tryParse(vm.teacherProgress['assessed']?.toString() ?? '0') ?? 0;
    final double percent = (double.tryParse(vm.teacherProgress['percentage']?.toString() ?? '0') ?? 0.0) / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [primaryBlue, accentBlue]),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PROGRES EVALUASI",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$done dari $total Siswa",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            percent >= 1.0 ? "🎉 Luar biasa! Semua tugas selesai." : "Selesaikan penilaian untuk melihat radar chart.",
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Student Tile dengan style _classTile dari Homepage Guru
  Widget _buildStudentTile(BuildContext context, dynamic student) {
    const int currentTahunAjaranId = 1;
    final List assessments = student['assessments_received'] ?? [];
    
    bool isDone = assessments.any((a) => 
      int.tryParse(a['tahun_ajaran_id']?.toString() ?? '') == currentTahunAjaranId
    );

    final String nis = student['siswa']?['NIS']?.toString() ?? student['NIS']?.toString() ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isDone) {
            Navigator.push(context, MaterialPageRoute(
              builder: (c) => GuruAssessmentReportDetailPage(siswa: student),
            ));
          } else {
            Navigator.push(context, MaterialPageRoute(
              builder: (c) => FormPenilaianPage(student: student),
            )).then((_) => _loadData());
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDone ? Border.all(color: Colors.green.shade200) : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
            ],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: isDone ? Colors.green.shade50 : primaryBlue.withOpacity(0.05),
                child: Text(
                  student['name']?[0] ?? "?",
                  style: TextStyle(
                    color: isDone ? Colors.green : primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Nama & NIS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "NIS: $nis",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Status Indicator
              if (isDone)
                const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    Text("SELESAI", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "NILAI",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.person_search_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text("Belum ada daftar siswa", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
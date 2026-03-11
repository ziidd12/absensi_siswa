import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/viewmodels/assessment_viewmodel.dart';
import 'package:absensi_siswa/models/assessment_model.dart';

class FormPenilaianPage extends StatefulWidget {
  final dynamic student;
  const FormPenilaianPage({super.key, required this.student});

  @override
  State<FormPenilaianPage> createState() => _FormPenilaianPageState();
}

class _FormPenilaianPageState extends State<FormPenilaianPage> {
  // Key: question_id, Value: score
  final Map<int, double> _scores = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentViewModel>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssessmentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Input Penilaian", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: vm.isLoading && vm.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudentProfile(),
                        const SizedBox(height: 25),
                        const Text("ASPEK PENILAIAN", 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 10),
                        
                        // Menampilkan kategori sebagai "Dropdown" (ExpansionTile)
                        ...vm.categories.map((category) {
                          return _buildCategoryGroup(category);
                        }).toList(),

                        const SizedBox(height: 25),
                        const Text("CATATAN TAMBAHAN", 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Masukkan feedback untuk siswa...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(vm),
              ],
            ),
    );
  }

  // Widget Profile Siswa
  Widget _buildStudentProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, 
            backgroundColor: Colors.blue.shade50, 
            child: const Icon(Icons.person, size: 35, color: Colors.blue)
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.student['name'] ?? "-", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("NIS: ${widget.student['siswa']?['NIS'] ?? widget.student['NIS'] ?? '-'}", 
                  style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget Kelompok Pertanyaan per Kategori
  Widget _buildCategoryGroup(dynamic category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(category.name, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.questions != null)
            ...category.questions.map<Widget>((question) {
              return _buildQuestionItem(question.id, question.questionText);
            }).toList()
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Tidak ada pertanyaan"),
            ),
        ],
      ),
    );
  }

  // Widget Item Pertanyaan dengan Slider/Input Skor
  Widget _buildQuestionItem(int id, String label) {
    _scores.putIfAbsent(id, () => 7.0); // Default nilai 7.0

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _scores[id]!,
                min: 0,
                max: 10,
                divisions: 10,
                label: _scores[id]!.toInt().toString(),
                onChanged: (val) {
                  setState(() {
                    _scores[id] = val;
                  });
                },
              ),
            ),
            Container(
              width: 45,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: Text(
                  _scores[id]!.toInt().toString(), 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildActionButtons(AssessmentViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: vm.isLoading ? null : () => _submit(vm),
          child: vm.isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("SIMPAN SEMUA NILAI", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  void _submit(AssessmentViewModel vm) async {
    // Mapping detail dengan konversi ke integer
    List<AssessmentDetail> details = _scores.entries.map((e) {
      return AssessmentDetail(
        questionId: e.key, 
        score: e.value.toInt(), // Konversi double slider ke int
      );
    }).toList();

    bool success = await vm.saveAssessment(
      evaluateeId: widget.student['id'],
      tahunAjaranId: 1, 
      details: details,
      notes: _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil menyimpan penilaian!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    }
  }
}
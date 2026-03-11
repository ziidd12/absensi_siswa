import 'package:flutter/material.dart';
import 'package:absensi_siswa/models/teacher_dashboard_model.dart';

class FormPenilaianScreen extends StatefulWidget {
  final SiswaPenilaian siswa;
  final VoidCallback? onSubmitted;

  const FormPenilaianScreen({
    Key? key,
    required this.siswa,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<FormPenilaianScreen> createState() => _FormPenilaianScreenState();
}

class _FormPenilaianScreenState extends State<FormPenilaianScreen> {
  final Map<int, double> _ratings = {};
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    // TODO: Load kategori from API
    setState(() {
      _isLoading = false;
      // Dummy data
      _kategoriList = [
        {'id': 1, 'name': 'Pengetahuan', 'description': 'Penguasaan materi'},
        {'id': 2, 'name': 'Keterampilan', 'description': 'Kemampuan praktik'},
        {'id': 3, 'name': 'Sikap', 'description': 'Perilaku dan etika'},
      ];
      for (var k in _kategoriList) {
        _ratings[k['id']] = 3.0;
      }
    });
  }

  String _getRatingLabel(double rating) {
    switch (rating.round()) {
      case 1: return 'Sangat Kurang';
      case 2: return 'Kurang';
      case 3: return 'Cukup';
      case 4: return 'Baik';
      case 5: return 'Sangat Baik';
      default: return 'Cukup';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Form Penilaian',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0047ff),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            widget.siswa.nama[0].toUpperCase(),
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.siswa.nama,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'NIS: ${widget.siswa.nis}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              if (widget.siswa.kelas != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Kelas: ${widget.siswa.kelas}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rating Categories
                  ..._kategoriList.map((kategori) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kategori['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (kategori['description'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            kategori['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final rating = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _ratings[kategori['id']] = rating.toDouble();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  rating <= (_ratings[kategori['id']] ?? 3)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: rating <= (_ratings[kategori['id']] ?? 3)
                                      ? Colors.amber
                                      : Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getRatingLabel(_ratings[kategori['id']] ?? 3),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 16),

                  // Catatan Field
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.note, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Catatan / Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _catatanController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan atau feedback untuk siswa...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Penilaian berhasil disimpan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        widget.onSubmitted?.call();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0047ff),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Penilaian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }
}
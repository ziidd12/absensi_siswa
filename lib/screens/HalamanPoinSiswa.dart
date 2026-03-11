import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:absensi_siswa/service/api_service.dart';

class HalamanPoinSiswa extends StatefulWidget {
  // Kita hilangkan 'required' biar nggak error merah di main_page
  final dynamic siswaId; 
  const HalamanPoinSiswa({super.key, this.siswaId});

  @override
  State<HalamanPoinSiswa> createState() => _HalamanPoinSiswaState();
}

class _HalamanPoinSiswaState extends State<HalamanPoinSiswa> {
  bool isLoading = true;
  Map<String, dynamic>? dataRating;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Kalau siswaId kosong, jangan nembak API dulu
    if (widget.siswaId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await ApiService.get('penilaian-siswa/${widget.siswaId}');
      if (mounted) {
        setState(() {
          dataRating = response['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print("Error load data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Kalau ID nggak ada, tampilin pesan ramah
    if (widget.siswaId == null && dataRating == null) {
      return const Scaffold(body: Center(child: Text("Sesi login tidak ditemukan.")));
    }

    double disiplin = double.tryParse(dataRating?['kedisiplinan']?.toString() ?? '0') ?? 0;
    double tim = double.tryParse(dataRating?['kerja_sama']?.toString() ?? '0') ?? 0;
    double tanggung = double.tryParse(dataRating?['tanggung_jawab']?.toString() ?? '0') ?? 0;
    double inisiatif = double.tryParse(dataRating?['inisiatif']?.toString() ?? '0') ?? 0;
    double totalAvg = (disiplin + tim + tanggung + inisiatif) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildCompactHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ringkasan Performa", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 12),
                    _buildMainScoreCard(totalAvg),
                    const SizedBox(height: 32),
                    const Text("Detail Penilaian", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 12),
                    _buildStructuredTile("Kedisiplinan", disiplin, Icons.timer_rounded, Colors.orange),
                    _buildStructuredTile("Kerja Sama Tim", tim, Icons.groups_rounded, Colors.blue),
                    _buildStructuredTile("Tanggung Jawab", tanggung, Icons.verified_user_rounded, Colors.green),
                    _buildStructuredTile("Inisiatif Kerja", inisiatif, Icons.auto_awesome_rounded, Colors.purple),
                    const SizedBox(height: 32),
                    _buildFeedback(dataRating?['catatan'] ?? "Belum ada catatan pembimbing."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return SliverAppBar(
      expandedHeight: 120, pinned: true, elevation: 0, automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text("Capaian Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]))),
      ),
    );
  }

  Widget _buildMainScoreCard(double avg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Skor Indeks", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                const SizedBox(height: 4),
                Text("${avg.toStringAsFixed(1)} / 5.0", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredTile(String title, double rating, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
            itemCount: 5,
            itemSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(String note) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.1))),
      child: Text("“$note”", style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}
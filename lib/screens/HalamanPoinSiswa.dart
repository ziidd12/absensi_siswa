import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:absensi_siswa/viewmodels/score_viewmodel.dart';
import 'package:absensi_siswa/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class HalamanPoinSiswa extends StatefulWidget {
  const HalamanPoinSiswa({super.key});

  @override
  State<HalamanPoinSiswa> createState() => _HalamanPoinSiswaState();
}

class _HalamanPoinSiswaState extends State<HalamanPoinSiswa> {
  @override
  void initState() {
    super.initState();
    // Panggil data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreViewModel>().fetchMyScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final scoreVM = Provider.of<ScoreViewModel>(context);

    // 1. Cek Sesi Login
    if (authVM.userId == null) {
      return const Scaffold(body: Center(child: Text("Sesi login tidak ditemukan.")));
    }

    // 2. Loading State
    if (scoreVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: () => scoreVM.fetchMyScores(),
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
                    _buildMainScoreCard(scoreVM.totalAvg),
                    const SizedBox(height: 32),
                    const Text("Detail Penilaian", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 12),
                    // Data diambil langsung dari getter ViewModel
                    _buildStructuredTile("Kedisiplinan", scoreVM.disiplin, Icons.timer_rounded, Colors.orange),
                    _buildStructuredTile("Kerja Sama Tim", scoreVM.tim, Icons.groups_rounded, Colors.blue),
                    _buildStructuredTile("Tanggung Jawab", scoreVM.tanggungJawab, Icons.verified_user_rounded, Colors.green),
                    _buildStructuredTile("Inisiatif Kerja", scoreVM.inisiatif, Icons.auto_awesome_rounded, Colors.purple),
                    const SizedBox(height: 32),
                    _buildFeedback(scoreVM.catatan),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget tampilan tetap sama sesuai permintaan ---

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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.1))),
      child: Text("“$note”", style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}
import 'dart:async';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:absensi_siswa/pages/login_page.dart';
// Import halaman absensi kelas yang kita bahas tadi
// import 'package:absensi_siswa/pages/absensi_kelas_screen.dart'; 

class GuruHomePage extends StatefulWidget {
  const GuruHomePage({super.key});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  String? _userName;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Update status jadwal tiap menit
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadProfile() async {
    final name = await TokenStorage.getUserName();
    setState(() => _userName = name);
  }

  void _handleLogout() async {
    await TokenStorage.clearAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Helper untuk menentukan status kelas (0: Belum, 1: Sedang Berlangsung, 2: Selesai)
  int _checkClassStatus(String timeRange) {
    try {
      final now = DateTime.now();
      final parts = timeRange.split(' - ');
      final startParts = parts[0].replaceAll('.', ':').split(':');
      final endParts = parts[1].replaceAll('.', ':').split(':');

      final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
      final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

      if (now.isBefore(startTime)) return 0;
      if (now.isAfter(endTime)) return 2;
      return 1; 
    } catch (e) {
      return 0;
    }
  }

  void _openAttendance(BuildContext context) async {
  final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);
  
  // 1. Coba panggil API
  await viewModel.createSession(1); 

  if (!mounted) return;

  // 2. Cek apakah datanya ada
  if (viewModel.sessionData != null && viewModel.sessionData!.tokenQr != null) {
    _showQRDialog(context, viewModel.sessionData!.tokenQr!);
  } else {
    // 3. Jika gagal, munculkan pesan error aslinya dari Viewmodel
    // Ini akan membantu kita tahu apakah masalahnya: Token habis, Server mati, atau Jadwal salah.
    String pesanError = viewModel.errorMessage ?? "Gagal: Jadwal mungkin sudah berakhir atau ID 1 tidak ada.";
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesanError), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5), // Lebih lama agar sempat terbaca
      ),
    );
  }
}

  void _showQRDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Scan QR Absensi", 
          textAlign: TextAlign.center, 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        content: SizedBox( // Membungkus dengan SizedBox agar ukurannya terukur
          width: 300, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Siswa silakan scan kode di bawah ini.", 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 13, color: Colors.grey)
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: QrImageView(
                  data: token, 
                  version: QrVersions.auto, 
                  size: 200.0,
                  gapless: false,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Token: $token", 
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueAccent
                )
              ),
            ],
          ),
        ),
        actions: [
          // HAPUS Center di sini, biarkan TextButton yang mengatur posisinya
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Selesai & Tutup", 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kehadiranVM = Provider.of<KehadiranViewmodel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, ${_userName ?? 'Guru'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _handleLogout)
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _loadProfile(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, kehadiranVM),
                  const SizedBox(height: 24),
                  
                  // MENU BARU: Navigasi Cepat
                  const Text("Menu Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _menuButton(context, "Absen Manual", Icons.fact_check_rounded, Colors.orange, () {
                        // Navigasi ke Halaman Absensi Kelas yang kita buat tadi
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const AbsensiKelasScreen()));
                      }),
                      const SizedBox(width: 12),
                      _menuButton(context, "Riwayat", Icons.history_rounded, Colors.purple, () {
                        // Ke halaman riwayat
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("Jadwal Mengajar Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _classTile(
                    title: "Matematika - XII RPL 1", time: "07.10 - 09.10", room: "LAB RPL 1", 
                    status: _checkClassStatus("07.10 - 09.10"),
                  ),
                  _classTile(
                    title: "Matematika - XII RPL 2", time: "10:30 - 12:00", room: "XII RPL 2", 
                    status: _checkClassStatus("10:30 - 12:00"),
                  ),
                ],
              ),
            ),
          ),
          if (kehadiranVM.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, KehadiranViewmodel vm) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF1E5EFF), Color(0xFF2A7CFF)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PRESENSI QR", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          const Text("Mulai Sesi Absensi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_2),
            label: const Text("TAMPILKAN QR CODE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: Colors.blueAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: vm.isLoading ? null : () => _openAttendance(context),
          ),
        ],
      ),
    );
  }

  Widget _classTile({required String title, required String time, required String room, required int status}) {
    Color color = status == 1 ? Colors.blue : (status == 2 ? Colors.green : Colors.grey);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: status == 1 ? Border.all(color: Colors.blue.shade200) : null,
      ),
      child: Row(
        children: [
          Icon(status == 2 ? Icons.check_circle : Icons.access_time_filled, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$time • $room", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (status == 1) 
            const Badge(label: Text("LIVE"), backgroundColor: Colors.red)
          else if (status == 2)
            const Text("SELESAI", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
import 'package:absensi_siswa/viewModels/kehadiran_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

class GuruHomePage extends StatefulWidget {
  const GuruHomePage({super.key});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final name = await TokenStorage.getUserName();
    setState(() => _userName = name);
  }

  // Fungsi yang dipanggil saat tombol "Buka Sesi Absen" ditekan
  void _openAttendance(BuildContext context) async {
    final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);

    // Request ke API (jadwalId sementara kita set 1)
    await viewModel.createSession(1);

    if (!mounted) return;

    // Jika data berhasil didapat dan ada token QR-nya
    if (viewModel.sessionData != null && viewModel.sessionData!.tokenQr != null) {
      _showQRDialog(context, viewModel.sessionData!.tokenQr!);
    } else {
      // Jika gagal, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Gagal mengambil data QR dari server"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Tampilan Popup (Dialog) untuk menampilkan QR Code
  void _showQRDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mengharuskan user menekan tombol tutup
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Scan QR Absensi", 
          textAlign: TextAlign.center, 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Siswa silakan melakukan scan pada kode QR di bawah ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(
                data: token, // Menggunakan token asli dari database
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 15),
            Text("Token Sesi: $token", 
              style: const TextStyle(fontSize: 10, color: Colors.blueGrey)
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Tutup Sesi QR", 
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
              )
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memantau state dari KehadiranViewmodel
    final kehadiranVM = Provider.of<KehadiranViewmodel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${_userName ?? 'Guru'}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Biru untuk Tombol Absensi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E5EFF), Color(0xFF2A7CFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white),
                          SizedBox(width: 8),
                          Text("ABSENSI KELAS", 
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("Mulai Sesi Sekarang?", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Klik tombol di bawah untuk mendapatkan QR Code terbaru untuk absensi siswa.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        // Nonaktifkan tombol jika sedang loading
                        onPressed: kehadiranVM.isLoading ? null : () => _openAttendance(context),
                        child: const Text("Buka Sesi Absen", 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Jadwal Hari Ini", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 12),
                _classTile(title: "Matematika", time: "08:00 AM", room: "Ruang 10", completed: true),
                _classTile(title: "Fisika Modern", time: "10:00 AM", room: "Lab Utama", active: true),
              ],
            ),
          ),
          
          // Indikator Loading di atas seluruh layar
          if (kehadiranVM.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // Widget kecil untuk menampilkan daftar kelas
  Widget _classTile({required String title, required String time, required String room, bool completed = false, bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? Colors.blue : Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Icon(completed ? Icons.check_circle : Icons.book, 
            color: completed ? Colors.green : Colors.blue
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$time • $room", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (completed) const Text("SELESAI", 
            style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
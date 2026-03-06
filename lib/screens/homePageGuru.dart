import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
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

  void _openAttendance(BuildContext context) async {
    final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);

    // Menjalankan request ke API
    await viewModel.createSession(1);

    if (!mounted) return;

    if (viewModel.sessionData != null && viewModel.sessionData!.tokenQr != null) {
      _showQRDialog(context, viewModel.sessionData!.tokenQr!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "Gagal mendapatkan token QR"),
          backgroundColor: Colors.red,
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
        title: const Text("Scan QR Absensi", 
          textAlign: TextAlign.center, 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        content: SizedBox( // PERBAIKAN UTAMA: Berikan SizedBox dengan lebar pasti
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Siswa silakan melakukan scan pada kode QR di bawah ini.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              // Container dengan ukuran tetap untuk mencegah error Intrinsic Dimensions
              Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]
                ),
                child: QrImageView(
                  data: token,
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  errorStateBuilder: (cxt, err) {
                    return const Center(child: Text("Gagal membuat QR"));
                  },
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                "Token: $token", 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500)
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => Navigator.pop(context), 
              child: const Text("Tutup Sesi QR", style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
          const SizedBox(height: 10),
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
            Text("Hello, ${_userName ?? 'Guru'}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
            ),
            Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, kehadiranVM),
                  const SizedBox(height: 24),
                  const Text("Jadwal Hari Ini", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
                  _classTile(title: "Pemrograman Mobile", time: "08:00 - 10:00", room: "LAB RPL 1", active: true),
                  _classTile(title: "Basis Data", time: "10:30 - 12:00", room: "XII RPL 2", completed: true),
                ],
              ),
            ),
          ),
          
          // Loading Overlay
          if (kehadiranVM.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, KehadiranViewmodel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E5EFF), Color(0xFF2A7CFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("PRESENSI DIGITAL", 
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12)
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Mulai Sesi Sekarang", 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const SizedBox(height: 8),
          const Text(
            "Klik tombol di bawah untuk membuat QR Code presensi siswa kelas Anda hari ini.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: vm.isLoading ? null : () => _openAttendance(context),
            child: const Text("BUKA SESI ABSEN", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }

  Widget _classTile({required String title, required String time, required String room, bool completed = false, bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? Colors.blue.shade300 : Colors.transparent, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: completed ? Colors.green.shade50 : Colors.blue.shade50,
              shape: BoxShape.circle
            ),
            child: Icon(completed ? Icons.check_circle : Icons.book, 
              color: completed ? Colors.green : Colors.blue, size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("$time • $room", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (completed) 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: const Text("SELESAI", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
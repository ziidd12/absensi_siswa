import 'dart:async';
import 'package:absensi_siswa/pages/jadwal_page.dart';
import 'package:absensi_siswa/viewmodels/jadwal_siswa.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:absensi_siswa/pages/login_page.dart';
import 'package:absensi_siswa/pages/absensi_manual_page.dart';
import 'package:absensi_siswa/pages/riwayat_page.dart';

// --- MODEL ---
class JadwalModel {
  final int id;
  final int kelasId;
  final int mapelId;
  final int guruId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final KelasRelasi kelas;
  final MapelRelasi mapel;

  JadwalModel({
    required this.id,
    required this.kelasId,
    required this.mapelId,
    required this.guruId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kelas,
    required this.mapel,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'],
      kelasId: json['kelas_id'],
      mapelId: json['mapel_id'],
      guruId: json['guru_id'],
      hari: json['hari']?.toString() ?? '',
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      kelas: KelasRelasi.fromJson(json['kelas']),
      mapel: MapelRelasi.fromJson(json['mapel']),
    );
  }
}

class KelasRelasi {
  final int id;
  final String tingkat;
  final String jurusan;
  final String nomorKelas;

  KelasRelasi({required this.id, required this.tingkat, required this.jurusan, required this.nomorKelas});

  factory KelasRelasi.fromJson(Map<String, dynamic> json) {
    return KelasRelasi(
      id: json['id'],
      tingkat: json['tingkat']?.toString() ?? '',
      jurusan: json['jurusan']?.toString() ?? '',
      nomorKelas: json['nomor_kelas']?.toString() ?? '', 
    );
  }

  String get namaLengkap => "$tingkat $jurusan $nomorKelas";
}

class MapelRelasi {
  final int id;
  final String namaMapel;

  MapelRelasi({required this.id, required this.namaMapel});

  factory MapelRelasi.fromJson(Map<String, dynamic> json) {
    return MapelRelasi(
      id: json['id'],
      namaMapel: json['nama_mapel']?.toString() ?? '',
    );
  }
}

// --- UI GURU HOME PAGE ---
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
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JadwalViewModel>(context, listen: false).fetchJadwal();
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

  void _navigateToManual(String kelas, String mapel, String timeRange) async {
    int status = _checkClassStatus(timeRange);

    if (status == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sabar Kak, kelas belum dimulai!"), backgroundColor: Colors.orange),
      );
      return;
    } else if (status == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ehh, jam mengajar sudah habis!"), backgroundColor: Colors.red),
      );
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi habis, silakan login ulang"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbsensiManualPage(namaKelas: kelas, mapel: mapel),
      ),
    );
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
    final jadwalVM = Provider.of<JadwalViewModel>(context, listen: false);

    int targetJadwalId = 1;
    if (jadwalVM.listJadwal.isNotEmpty) {
      final active = jadwalVM.listJadwal.firstWhere(
        (j) => _checkClassStatus("${j.jamMulai} - ${j.jamSelesai}") == 1,
        orElse: () => jadwalVM.listJadwal.first
      );
      targetJadwalId = active.id;
    }

    await viewModel.createSession(targetJadwalId); 

    if (!mounted) return;

    if (viewModel.sessionData != null && viewModel.sessionData!.tokenQr != null) {
      _showQRDialog(context, viewModel.sessionData!.tokenQr!);
    } else {
      String pesanError = viewModel.errorMessage ?? "Gagal membuat sesi absensi.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError), backgroundColor: Colors.red),
      );
    }
  }

  void _showQRDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Scan QR Absensi", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          // PERBAIKAN: Memberikan batasan lebar agar tidak error Intrinsic Dimensions
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Siswa silakan scan kode di bawah ini.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              QrImageView(
                data: token, 
                version: QrVersions.auto, 
                size: 200.0,
                // Tambahkan padding agar QR tidak menempel ke tepi
                padding: const EdgeInsets.all(10),
              ),
              const SizedBox(height: 15),
              Text("Token: $token", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kehadiranVM = Provider.of<KehadiranViewmodel>(context);
    final jadwalVM = Provider.of<JadwalViewModel>(context);

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
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _handleLogout)],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => await jadwalVM.fetchJadwal(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, kehadiranVM),
                  const SizedBox(height: 24),
                  const Text("Menu Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _menuButton(context, "Jadwal", Icons.calendar_month_rounded, Colors.orange, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const JadwalPage()));
                      }),
                      const SizedBox(width: 12),
                      _menuButton(context, "Riwayat", Icons.history_rounded, Colors.purple, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPage()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Jadwal Mengajar Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (jadwalVM.isLoading && jadwalVM.listJadwal.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (jadwalVM.listJadwal.isEmpty)
                    const Center(child: Text("Tidak ada jadwal hari ini.", style: TextStyle(color: Colors.grey)))
                  else
                    Column(
                      children: jadwalVM.listJadwal.map((jadwal) {
                        final timeRange = "${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)}";
                        return _classTile(
                          title: "${jadwal.mapel.namaMapel} - ${jadwal.kelas.namaLengkap}", 
                          time: timeRange, 
                          status: _checkClassStatus(timeRange),
                          onTap: () => _navigateToManual(jadwal.kelas.namaLengkap, jadwal.mapel.namaMapel, timeRange),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          if (kehadiranVM.isLoading) const Center(child: CircularProgressIndicator()),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 50)),
            onPressed: vm.isLoading ? null : () => _openAttendance(context),
          ),
        ],
      ),
    );
  }

  Widget _classTile({required String title, required String time, required int status, required VoidCallback onTap}) {
    Color color = status == 1 ? Colors.blue : (status == 2 ? Colors.green : Colors.grey);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(14),
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
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              if (status == 1) const Badge(label: Text("LIVE"), backgroundColor: Colors.red)
              else if (status == 2) const Text("SELESAI", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
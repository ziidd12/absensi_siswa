import 'dart:async';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:absensi_siswa/utils/token_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreenSiswa extends StatefulWidget {
  const HomeScreenSiswa({super.key});

  @override
  State<HomeScreenSiswa> createState() => _HomeScreenSiswaState();
}

class _HomeScreenSiswaState extends State<HomeScreenSiswa> {
  String? _name;
  String? _nis;
  bool _isScanning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    initializeDateFormatting('id_ID', null);
    
    // Auto-refresh UI setiap menit untuk update status tombol "Terkunci/Absen" secara otomatis
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
    final nis = await TokenStorage.getUserSerialNumber();
    if (!mounted) return;
    setState(() {
      _name = name;
      _nis = nis;
    });
  }

  // ===================== LOGIKA STATUS WAKTU =====================
  // Return: 0 = Belum Mulai, 1 = Aktif, 2 = Sudah Lewat
  int _getTimeStatus(String timeRange) {
    try {
      final now = DateTime.now();
      final parts = timeRange.split(' - ');
      if (parts.length != 2) return 0;

      final startParts = parts[0].split('.');
      final endParts = parts[1].split('.');

      final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
      final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

      if (now.isBefore(startTime)) return 0;
      if (now.isAfter(endTime)) return 2;
      return 1;
    } catch (e) {
      return 0;
    }
  }

  // ===================== SCANNER DENGAN OVERLAY =====================
  void _openScanner(String mapel) async {
    _isScanning = false;
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Scan QR: $mapel"),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  if (_isScanning) return;
                  final code = capture.barcodes.first.rawValue;
                  if (code != null) {
                    _isScanning = true;
                    Navigator.pop(context, code);
                  }
                },
              ),
              // Scanner Overlay (Kotak Bidik)
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      _processAttendance(result, mapel);
    }
  }

  void _processAttendance(String token, String namaMapel) async {
    final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);
    
    // Nanti di ViewModel, pastikan scanQR mengirim koordinat asli jika ingin pakai radius
    // Untuk tes sementara kita pakai 0.0 dulu
    final result = await viewModel.scanQR(token, 0.0, 0.0, namaMapel);

    if (!mounted) return;

    if (result != null) {
      // Jika Sukses
      _showResultBottomSheet(true, "Berhasil absen di mata pelajaran $namaMapel");
    } else {
      // Jika Gagal (Di sini "Satpam Kelas" akan beraksi)
      // Kita ambil pesan error langsung dari ViewModel yang didapat dari Laravel
      String pesanError = viewModel.errorMessage ?? "Gagal melakukan absensi.";
      _showResultBottomSheet(false, pesanError);
    }
  }

  void _showResultBottomSheet(bool success, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(success ? "Sukses!" : "Gagal", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Tutup"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===================== UI BUILDER =====================
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildDateStrip(today),
                const SizedBox(height: 25),
                _buildScheduleList(formattedDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blueAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(radius: 30, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white, size: 35)),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name ?? "Loading...", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("NIS : ${_nis ?? '-'}", style: TextStyle(color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateStrip(DateTime today) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final date = today.add(Duration(days: index));
          final isToday = index == 0;
          return Column(
            children: [
              Text(DateFormat('EEE', 'id_ID').format(date), style: TextStyle(fontSize: 12, color: isToday ? Colors.blueAccent : Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: 45, height: 45, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? Colors.blueAccent : Colors.grey.shade50, 
                  borderRadius: BorderRadius.circular(12),
                  border: isToday ? null : Border.all(color: Colors.grey.shade200)
                ),
                child: Text(date.day.toString(), style: TextStyle(color: isToday ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleList(String formattedDate) {
    final viewModel = Provider.of<KehadiranViewmodel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jadwal Pelajaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(formattedDate, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 15),
          if (viewModel.jadwalSiswa.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Tidak ada jadwal hari ini", style: TextStyle(color: Colors.grey))))
          else
            ...viewModel.jadwalSiswa.map((mapel) {
              int timeStatus = _getTimeStatus(mapel.jam);
              return _buildMapelCard(mapel.nama, mapel.jam, mapel.isAbsen, timeStatus);
            }),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMapelCard(String title, String time, bool isAbsen, int timeStatus) {
    // timeStatus: 0 = Belum mulai, 1 = Aktif, 2 = Sudah Lewat
    bool canAbsen = timeStatus == 1 && !isAbsen;

    Color statusColor;
    String btnText;

    if (isAbsen) {
      statusColor = Colors.green;
      btnText = "Hadir";
    } else if (timeStatus == 0) {
      statusColor = Colors.grey.shade400;
      btnText = "Nanti";
    } else if (timeStatus == 2) {
      statusColor = Colors.red.shade300;
      btnText = "Lewat";
    } else {
      statusColor = Colors.blueAccent;
      btnText = "Absen";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: isAbsen ? Border.all(color: Colors.green.shade100, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isAbsen ? Icons.verified : Icons.menu_book_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF334155))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ]
            ),
          ),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: canAbsen ? () => _openScanner(title) : null,
              child: Text(btnText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
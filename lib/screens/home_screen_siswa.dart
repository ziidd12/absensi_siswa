import 'dart:async';
import 'package:absensi_siswa/viewmodels/jadwal_siswa.dart';
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
    
    // Fetch data saat pertama kali buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JadwalViewModel>(context, listen: false).fetchJadwal();
    });

    // Auto-refresh UI setiap menit untuk update status tombol "Absen"
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
  int _getTimeStatus(String jamMulai, String jamSelesai) {
    try {
      final now = DateTime.now();
      
      // Standarisasi format waktu (HH:mm)
      final startParts = jamMulai.replaceAll('.', ':').split(':');
      final endParts = jamSelesai.replaceAll('.', ':').split(':');

      final startTime = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
      final endTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

      if (now.isBefore(startTime)) return 0; // Belum mulai
      if (now.isAfter(endTime)) return 2;    // Sudah lewat
      return 1; // Aktif (Bisa Absen)
    } catch (e) {
      return 0;
    }
  }

  // ===================== SCANNER QR =====================
  void _openScanner(String mapel) async {
    _isScanning = false;
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Scan QR: $mapel"),
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
              Center(
                child: Container(
                  width: 250, height: 250,
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

  // ===================== PROSES ABSENSI (UPDATE LOGIC) =====================
  void _processAttendance(String token, String namaMapel) async {
    final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);
    
    // PERUBAHAN: Sekarang hanya mengirim token (Lokasi dihapus sesuai ViewModel baru)
    final result = await viewModel.scanQR(token);

    if (!mounted) return;

    if (result != null && result.status == 'success') {
      // PERUBAHAN: Menampilkan message asli dari Laravel (info poin akan muncul di sini)
      _showResultBottomSheet(true, result.message ?? "Berhasil absen di mata pelajaran $namaMapel");
      
      // Opsional: Refresh jadwal agar status tombol berubah
      Provider.of<JadwalViewModel>(context, listen: false).fetchJadwal();
    } else {
      String pesanError = viewModel.errorMessage ?? "Gagal melakukan absensi.";
      _showResultBottomSheet(false, pesanError);
    }
  }

  void _showResultBottomSheet(bool success, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 30),
            Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(success ? "Absensi Berhasil!" : "Absensi Gagal", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.blueAccent : Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<JadwalViewModel>(context, listen: false).fetchJadwal(),
        child: CustomScrollView(
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
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.blueAccent,
      elevation: 0,
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
            padding: const EdgeInsets.fromLTRB(25, 80, 25, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(radius: 28, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 35, color: Colors.white)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name ?? "Siswa", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text("NIS : ${_nis ?? '-'}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    ],
                  ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final date = today.add(Duration(days: index));
          final isToday = index == 0;
          return Column(
            children: [
              Text(DateFormat('EEE', 'id_ID').format(date), style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? Colors.blueAccent : Colors.grey)),
              const SizedBox(height: 10),
              Container(
                width: 45, height: 45, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? Colors.blueAccent : Colors.grey.shade50, 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(date.day.toString(), style: TextStyle(color: isToday ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleList(String formattedDate) {
    final jadwalVM = Provider.of<JadwalViewModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jadwal Pelajaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formattedDate, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          if (jadwalVM.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          else if (jadwalVM.listJadwal.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text("Tidak ada jadwal hari ini", style: TextStyle(color: Colors.grey)),
              ],
            )))
          else
            ...jadwalVM.listJadwal.map((jadwal) {
              int timeStatus = _getTimeStatus(jadwal.jamMulai, jadwal.jamSelesai);
              
              // Status Absen (Misal dari API Jadwal ada field is_absen)
              bool isAbsen = false; // Anda bisa ganti dengan: jadwal.statusAbsen == 'hadir'

              return _buildMapelCard(
                jadwal.mapel.namaMapel, 
                "${jadwal.jamMulai.substring(0,5)} - ${jadwal.jamSelesai.substring(0,5)}", 
                isAbsen, 
                timeStatus
              );
            }),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMapelCard(String title, String time, bool isAbsen, int timeStatus) {
    bool canAbsen = timeStatus == 1 && !isAbsen;
    Color statusColor = isAbsen ? Colors.green : (timeStatus == 0 ? Colors.grey : (timeStatus == 2 ? Colors.red : Colors.blueAccent));
    String btnText = isAbsen ? "Hadir" : (timeStatus == 0 ? "Nanti" : (timeStatus == 2 ? "Lewat" : "Absen"));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isAbsen ? Icons.verified_user_rounded : Icons.menu_book_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ]
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                disabledBackgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.white,
                elevation: canAbsen ? 2 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: canAbsen ? () => _openScanner(title) : null,
              child: Text(btnText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: canAbsen ? Colors.white : Colors.grey.shade400)),
            ),
          ),
        ],
      ),
    );
  }
}
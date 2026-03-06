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
  
  // Flag untuk mencegah scan ganda yang menyebabkan black screen
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    initializeDateFormatting('id_ID', null);
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

  // ===================== SCANNER (FIXED) =====================
  void _openScanner(String mapel) async {
    // Reset flag sebelum membuka scanner
    _isScanning = false;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Scan QR: $mapel"),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              if (_isScanning) return; // Jika sudah terdeteksi sekali, abaikan sisanya

              final code = capture.barcodes.first.rawValue;
              if (code != null) {
                _isScanning = true; // Kunci agar tidak pop dua kali
                Navigator.pop(context, code); // Kembali ke Home dengan membawa data
              }
            },
          ),
        ),
      ),
    );

    // Kembali ke Home, proses absensi jika result tidak null
    if (result != null && mounted) {
      _processAttendance(result);
    }
  }

  void _processAttendance(String token) async {
    final viewModel = Provider.of<KehadiranViewmodel>(context, listen: false);
    final result = await viewModel.scanQR(token, 0.0, 0.0);

    if (!mounted) return;

    _showMessage(
      result != null ? "Absen Berhasil" : "Absen Gagal",
      result != null
          ? "Absensi Anda telah berhasil dicatat."
          : viewModel.errorMessage ?? "Sesi tidak ditemukan atau sudah berakhir.",
      isSuccess: result != null,
    );
  }

  void _showMessage(String title, String msg, {bool isSuccess = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: TextStyle(color: isSuccess ? Colors.blue : Colors.red)),
        content: Text(msg),
        actions: [
          TextButton(
            // HANYA Navigator.pop(context) untuk menutup dialog saja
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // ===================== UI TETAP SAMA =====================
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildDateStrip(today),
            const SizedBox(height: 25),
            _buildScheduleList(formattedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.blue)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_name ?? "Siswa", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("NIS : ${_nis ?? '-'}", style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip(DateTime today) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final date = today.add(Duration(days: index));
          final isToday = index == 0;
          return Column(
            children: [
              Text(DateFormat('EEE', 'id_ID').format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 5),
              Container(
                width: 40, height: 40, alignment: Alignment.center,
                decoration: BoxDecoration(color: isToday ? Colors.blue : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                child: Text(date.day.toString(), style: TextStyle(color: isToday ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleList(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Jadwal Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          _buildMapelCard("Senam", "06.30 - 07.10", Icons.fitness_center),
          _buildMapelCard("Matematika", "07.10 - 09.10", Icons.calculate),
          _buildMapelCard("B. Indonesia", "09.25 - 11.25", Icons.menu_book),
          _buildMapelCard("Konsentrasi RPL", "12.30 - 14.30", Icons.code, isActive: true),
          _buildMapelCard("BK", "14.30 - 15.10", Icons.psychology),
        ],
      ),
    );
  }

  Widget _buildMapelCard(String title, String time, IconData icon, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.blue : Colors.grey.shade300,
              foregroundColor: isActive ? Colors.white : Colors.grey,
            ),
            onPressed: isActive ? () => _openScanner(title) : null,
            child: Text(isActive ? "Absen" : "Terkunci"),
          ),
        ],
      ),
    );
  }
}
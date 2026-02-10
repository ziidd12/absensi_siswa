import 'package:absensi_siswa/viewModels/kehadiran_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

class HomeScreenSiswa extends StatefulWidget {
  const HomeScreenSiswa({super.key});

  @override
  State<HomeScreenSiswa> createState() => _HomeScreenSiswaState();
}

class _HomeScreenSiswaState extends State<HomeScreenSiswa> {
  String? _name;
  String? _nis;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  // ===================== SCANNER =====================
  void _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Scan QR Absensi")),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;

                if (code != null) {
                  Navigator.pop(context, code);
                }
              }
            },
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      _processAttendance(result);
    }
  }

  // ===================== ABSENSI =====================
  void _processAttendance(String token) async {
    final viewModel =
        Provider.of<KehadiranViewmodel>(context, listen: false);

    final result = await viewModel.scanQR(token, 0.0, 0.0);

    if (!mounted) return;

    // ✅ FIX DI SINI (TANPA UBAH STRUKTUR)
    if (result != null) {
      _showMessage(
        "Absen Berhasil",
        "Absensi Anda telah tercatat.",
      );
    } else {
      _showMessage(
        "Absen Gagal",
        viewModel.errorMessage ?? "Token tidak valid.",
      );
    }
  }

  // ===================== NOTIF + AUTO BACK =====================
  void _showMessage(String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext)
                  .popUntil((route) => route.isFirst);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                /// ================= PROFILE =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name ?? "Loading...",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "NIS : ${_nis ?? '-'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= JADWAL =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Jadwal XII RPL 2 Hari Ini",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.blue),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),

                        buildSchedule("Senam", "6.30 - 7.10"),
                        buildSchedule("Matematika", "7.10 - 9.10"),
                        buildSchedule("B. Indo", "9.25 - 11.25"),
                        buildSchedule("Konsentrasi RPL", "12.30 - 14.30"),
                        buildSchedule("BK", "14.30 - 15.10"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Rekap Absensi Siswa",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: const [
                          RekapCard("Alpha", "12", Colors.red),
                          RekapCard("Dispen", "1", Colors.blue),
                          RekapCard("Izin", "200", Colors.green),
                          RekapCard("Sakit", "12", Colors.orange),
                        ],
                      ),

                      /// ================= QR BUTTON =================
                      GestureDetector(
                        onTap: _openScanner,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black26)
                            ],
                          ),
                          child: const Icon(Icons.qr_code_scanner,
                              size: 40, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSchedule(String subject, String time) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject,
                style: const TextStyle(color: Colors.white)),
            Text(time,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
}

/// ================= REKAP CARD =================
class RekapCard extends StatelessWidget {
  final String title, value;
  final Color color;

  const RekapCard(this.title, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 5)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

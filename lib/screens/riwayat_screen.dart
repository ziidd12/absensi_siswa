import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec.yaml untuk format tanggal

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil data riwayat dari API saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KehadiranViewmodel>().fetchRiwayatSiswa();
    });
  }

  // Fungsi pembantu untuk mengelompokkan data berdasarkan tanggal
  Map<String, List<dynamic>> groupHistoryByDate(List<dynamic> history) {
    Map<String, List<dynamic>> grouped = {};
    for (var item in history) {
      // Ambil tanggal saja dari waktu_scan (YYYY-MM-DD)
      String date = item['waktu_scan'].toString().split(' ')[0];
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KehadiranViewmodel>();
    final groupedData = groupHistoryByDate(vm.riwayatReal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Riwayat Absensi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Aktivitas Absensi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                if (vm.riwayatReal.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Belum ada riwayat absensi."),
                    ),
                  ),

                // Menampilkan riwayat berdasarkan tanggal secara dinamis
                ...groupedData.entries.map((entry) {
                  String tanggalRaw = entry.key;
                  List<dynamic> listMapel = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: ExpansionTile(
                      leading: const Icon(Icons.calendar_month, color: Colors.blue),
                      title: Text(
                        // Mengubah YYYY-MM-DD menjadi format yang lebih enak dibaca
                        tanggalRaw, 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${listMapel.length} Mata Pelajaran"),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      children: listMapel.map((item) {
                        // Ambil jam dari waktu_scan
                        String jamScan = item['waktu_scan'].toString().split(' ')[1].substring(0, 5);
                        String namaMapel = item['sesi']['jadwal']['mapel']['nama_mapel'] ?? "Mapel";
                        bool isHadir = item['status'] == 'hadir';

                        return _buildDetailItem(namaMapel, "Absen pada: $jamScan", isHadir);
                      }).toList(),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 10),
                const Text("Hari Lainnya", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                _buildLockedDay("Riwayat Terlampaui"),
              ],
            ),
    );
  }

  Widget _buildDetailItem(String title, String time, bool isHadir) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHadir ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isHadir ? Colors.green.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isHadir ? Icons.check_circle : Icons.cancel,
            color: isHadir ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHadir ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isHadir ? "HADIR" : "TIDAK HADIR",
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedDay(String date) {
    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.lock_outline, color: Colors.grey),
        title: Text(date, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
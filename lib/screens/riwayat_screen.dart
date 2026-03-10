import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KehadiranViewmodel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Riwayat Absensi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Minggu Ini",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          // Bagian ini yang kamu mau: ExpansionTile (Bisa diklik & muncul detail)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            child: ExpansionTile(
              leading: const Icon(Icons.calendar_month, color: Colors.blue),
              title: const Text(
                "Senin, 02 Maret 2026", // Header Hari
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${vm.jadwalSiswa.length} Mata Pelajaran"),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              children: vm.jadwalSiswa.map((item) {
                // Ini Detail yang muncul pas diklik
                return _buildDetailItem(item.nama, item.jam, item.isAbsen);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 10),
          _buildLockedDay("Selasa, 03 Maret 2026"),
          _buildLockedDay("Rabu, 04 Maret 2026"),
        ],
      ),
    );
  }

  // Widget untuk isi detail di dalam ExpansionTile
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
              isHadir ? "HADIR" : "Belum Di Mulai",
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buat hari lain yang belum ada datanya
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
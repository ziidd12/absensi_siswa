import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy (Nanti ini diganti data dari API Laravel)
    final List<Map<String, dynamic>> dataRiwayat = [
      {
        'mapel': 'Matematika',
        'kelas': 'XII PPLG 1',
        'tanggal': 'Selasa, 10 Maret 2026',
        'jam': '07.10 - 09.10',
        'hadir': 32,
        'sakit': 1,
        'izin': 2,
        'alfa': 0,
      },
      {
        'mapel': 'Pemrograman Mobile',
        'kelas': 'XII PPLG 2',
        'tanggal': 'Senin, 09 Maret 2026',
        'jam': '10.30 - 12.00',
        'hadir': 30,
        'sakit': 0,
        'izin': 0,
        'alfa': 5,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Riwayat Presensi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dataRiwayat.length,
        itemBuilder: (context, index) {
          final item = dataRiwayat[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(item['mapel'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("${item['kelas']} • ${item['jam']}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                      Text(item['tanggal'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    // Nanti navigasi ke detail per nama siswa
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statusBadge("Hadir", item['hadir'].toString(), Colors.green),
                      _statusBadge("Sakit", item['sakit'].toString(), Colors.orange),
                      _statusBadge("Izin", item['izin'].toString(), Colors.blue),
                      _statusBadge("Alfa", item['alfa'].toString(), Colors.red),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
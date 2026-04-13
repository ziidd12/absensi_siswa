import 'package:flutter/material.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List hari untuk menu utama jadwal
    final List<Map<String, dynamic>> daftarHari = [
      {'hari': 'SENIN', 'icon': Icons.calendar_today, 'color': Colors.blue},
      {'hari': 'SELASA', 'icon': Icons.calendar_today, 'color': Colors.green},
      {'hari': 'RABU', 'icon': Icons.calendar_today, 'color': Colors.orange},
      {'hari': 'KAMIS', 'icon': Icons.calendar_today, 'color': Colors.red},
      {'hari': 'JUMAT', 'icon': Icons.calendar_today, 'color': Colors.teal},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Jadwal Mengajar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daftarHari.length,
        itemBuilder: (context, index) {
          final item = daftarHari[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              onTap: () => _showDetailJadwal(context, item['hari']),
              leading: CircleAvatar(
                backgroundColor: item['color'].withOpacity(0.1),
                child: Icon(item['icon'], color: item['color'], size: 20),
              ),
              title: Text(item['hari'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Lihat detail kelas & jam"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  // Fungsi Popup Detail (Nanti ini yang bakal narik data dari API)
  void _showDetailJadwal(BuildContext context, String hari) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Jadwal - $hari", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // Contoh Item Detail (Nanti di-looping pakai data API)
              _buildDetailItem("Matematika", "XII PPLG 2", "20:10 - 21:10", "LAB RPL 1"),
              const Divider(),
              _buildDetailItem("Matematika", "XII PPLG 1", "20:10 - 21:10", "LAB RPL 1"),
              
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String mapel, String kelas, String jam, String ruang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mapel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(kelas, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                Text("$jam • $ruang", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
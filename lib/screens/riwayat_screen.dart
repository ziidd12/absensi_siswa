import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// ================= HEADER =================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: Colors.blue, size: 28),
                    SizedBox(width: 8),

                    Text(
                      "Riwayat Absensi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= LIST =================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [

                    RiwayatCard(
                      tanggal: "01 Feb 2026",
                      status: "Hadir",
                      jam: "06:45",
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),

                    RiwayatCard(
                      tanggal: "02 Feb 2026",
                      status: "Alpha",
                      jam: "-",
                      color: Colors.red,
                      icon: Icons.cancel,
                    ),

                    RiwayatCard(
                      tanggal: "03 Feb 2026",
                      status: "Izin",
                      jam: "07:10",
                      color: Colors.orange,
                      icon: Icons.edit_note,
                    ),

                    RiwayatCard(
                      tanggal: "04 Feb 2026",
                      status: "Sakit",
                      jam: "06:55",
                      color: Colors.blue,
                      icon: Icons.medical_services,
                    ),

                    RiwayatCard(
                      tanggal: "05 Feb 2026",
                      status: "Hadir",
                      jam: "06:40",
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= CARD =================
class RiwayatCard extends StatelessWidget {
  final String tanggal;
  final String status;
  final String jam;
  final Color color;
  final IconData icon;

  const RiwayatCard({
    super.key,
    required this.tanggal,
    required this.status,
    required this.jam,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  tanggal,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Jam: $jam",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// STATUS
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

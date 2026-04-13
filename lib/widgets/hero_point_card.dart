import 'package:flutter/material.dart';

class HeroPointCard extends StatelessWidget {
  final int saldo;
  final String status;

  const HeroPointCard({super.key, required this.saldo, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Pakai Gradient biar kelihatan mewah kaya aplikasi e-wallet
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Poin Kedisiplinan", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nanti angka ini diambil dari kolom current_balance di database
              Text(
                "$saldo Pts",
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              // Status user berdasarkan jumlah poin
              Chip(
                label: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
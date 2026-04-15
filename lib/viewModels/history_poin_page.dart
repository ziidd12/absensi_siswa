import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Tambahkeun 'intl' di pubspec.yaml keur format tanggal
import '../../models/poin_history_model.dart';
import '../../service/api_service.dart';

class HistoryPoinPage extends StatelessWidget {
  const HistoryPoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Poin Store'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<PoinHistory>>(
        future: ApiService.fetchPoinHistory(), // Manggil fungsi nu bieu dijieun
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat poin.'));
          }

          final histories = snapshot.data!;

          return ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final item = histories[index];
              final isPositive = item.poinPerubahan > 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      isPositive ? Icons.add : Icons.remove,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    item.keterangan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt),
                  ),
                  trailing: Text(
                    '${isPositive ? '+' : ''}${item.poinPerubahan}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';


class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.qr_code,
            size: 180,
          ),
          SizedBox(height: 12),
          Text(
            'Scan QR Absensi',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

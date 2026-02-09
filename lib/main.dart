import 'package:absensi_siswa/screens/LaporanScreenGuru.dart';
import 'package:absensi_siswa/screens/ProfileGuru.dart';
import 'package:absensi_siswa/pages/guruHomePage.dart';
import 'package:absensi_siswa/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuruMainPage(),
    );
  }
}

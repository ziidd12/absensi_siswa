import 'package:absensi_siswa/screens/LaporanScreenGuru.dart';
import 'package:absensi_siswa/screens/ProfileGuru.dart';
import 'package:absensi_siswa/screens/homePageGuru.dart';
import 'package:flutter/material.dart';

class GuruMainPage extends StatefulWidget {
  const GuruMainPage({super.key});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  int _currentIndex = 0;

  // HAPUS kata 'const' di depan List ini. 
  // Karena LaporanScreen akan butuh akses Provider, sebaiknya jangan const di level ini.
  final List<Widget> _pages = [
    const GuruHomePage(),
    const Laporanscreenguru(), // <--- PASTIKAN NAMA CLASS INI SAMA DENGAN DI FILE LaporanScreenGuru.dart
    const GuruProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
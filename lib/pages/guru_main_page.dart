import 'package:absensi_siswa/screens/LaporanScreenGuru.dart';
import 'package:absensi_siswa/screens/ProfileGuru.dart';
import 'package:absensi_siswa/screens/homePageGuru.dart';
// Nanti kita buat file ini, sekarang kita buat placeholder dulu
import 'package:absensi_siswa/screens/penilaian/pilih_siswa_penilaian.dart'; 
import 'package:flutter/material.dart';

class GuruMainPage extends StatefulWidget {
  const GuruMainPage({super.key});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  int _currentIndex = 0;

  // List halaman sekarang jadi 4
  final List<Widget> _pages = [
    const GuruHomePage(),            // Halaman Home
    const PilihSiswaPenilaianPage(), // Halaman Penilaian Baru
    const Laporanscreenguru(),       // Halaman Reports
    const GuruProfilePage(),         // Halaman Profile
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
        // Ubah jadi fixed supaya ikonnya tidak goyang saat ada 4 menu
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent, 
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: "Penilaian"), // <--- ICON BARU
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
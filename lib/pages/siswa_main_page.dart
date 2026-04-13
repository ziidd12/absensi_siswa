import 'package:absensi_siswa/screens/home_screen_siswa.dart';
import 'package:absensi_siswa/screens/profile_screen.dart';
import 'package:absensi_siswa/screens/riwayat_screen.dart';
import 'package:absensi_siswa/screens/HalamanPoinSiswa.dart'; 
import 'package:absensi_siswa/screens/store_page.dart'; // Import halaman store baru
import 'package:flutter/material.dart';

class SiswaMainPage extends StatefulWidget {
  const SiswaMainPage({super.key});

  @override
  State<SiswaMainPage> createState() => _SiswaMainPageState();
}

class _SiswaMainPageState extends State<SiswaMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List halaman - Urutan sesuai dengan item di BottomNavigationBar
    final List<Widget> _pages = [
      const HomeScreenSiswa(),    // Index 0
      const RiwayatScreen(),      // Index 1
      const HalamanPoinSiswa(),   // Index 2 (Poin Penilaian Guru)
      const StorePage(),          // Index 3 (Store & Poin Absen)
      const ProfilePage(),        // Index 4
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed, // Tetap fixed meskipun 5 menu
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Absensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_rounded), 
                label: 'Penilaian Guru',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_rounded), 
                label: 'Item', // Fitur Store baru
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
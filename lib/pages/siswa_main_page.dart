import 'package:absensi_siswa/screens/home_screen_siswa.dart';
import 'package:absensi_siswa/screens/profile_screen.dart';
import 'package:absensi_siswa/screens/riwayat_screen.dart';
import 'package:absensi_siswa/screens/HalamanPoinSiswa.dart'; // Import halaman poin
import 'package:flutter/material.dart';

class SiswaMainPage extends StatefulWidget {
  const SiswaMainPage({super.key});

  @override
  State<SiswaMainPage> createState() => _SiswaMainPageState();
}

class _SiswaMainPageState extends State<SiswaMainPage> {
  int _currentIndex = 0;

  // GUNAKAN ID DARI DATABASE KAMU
  // Misal kita mau login sebagai Ahmad Zidan, maka pakai angka 1
  final int currentSiswaId = 1; 

  @override
  Widget build(BuildContext context) {
    // List halaman ditaruh di dalam build
    final List<Widget> _pages = [
      const HomeScreenSiswa(),
      const RiwayatScreen(),
      HalamanPoinSiswa(siswaId: currentSiswaId), // Ini akan mengirim angka 1 ke API
      const ProfilePage(),
    ];
    
    // ... sisa kode build Scaffold kamu tetap sama

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
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
            type: BottomNavigationBarType.fixed,
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
                label: 'Poin',
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
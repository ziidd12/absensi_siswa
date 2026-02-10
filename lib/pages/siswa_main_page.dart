import 'package:absensi_siswa/screens/home_screen_siswa.dart';
import 'package:absensi_siswa/screens/profile_screen.dart';
import 'package:absensi_siswa/screens/riwayat_screen.dart';
import 'package:flutter/material.dart';

class SiswaMainPage extends StatefulWidget {
  const SiswaMainPage({super.key});

  @override
  State<SiswaMainPage> createState() => _SiswaMainPageState();
}

class _SiswaMainPageState extends State<SiswaMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreenSiswa(),
    RiwayatScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      /// ===== BODY =====
      body: SafeArea(
        child: _pages[_currentIndex],
      ),

      /// ===== BOTTOM NAVBAR =====
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

            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,

            type: BottomNavigationBarType.fixed,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Riwayat',
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

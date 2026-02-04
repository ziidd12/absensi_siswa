import 'dart:async';
import 'package:absensi_siswa/pages/login_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D6E9E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mengganti Icon dengan Image Asset
            Image.asset(
              'assets/images/absen.png',
              width: 150, // Kamu bisa sesuaikan ukurannya di sini
              height: 150,
              fit: BoxFit.contain,
              // Jika gambar ingin dibuat putih polos (seperti icon), 
              // gunakan color & colorBlendMode di bawah ini:
              // color: Colors.white,
              // colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 30),
            // Indikator loading yang lebih halus
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
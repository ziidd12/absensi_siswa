import 'package:absensi_siswa/pages/guru_main_page.dart';
import 'package:absensi_siswa/pages/siswa_main_page.dart';
import 'package:absensi_siswa/pages/login_page.dart';
import 'package:absensi_siswa/screens/home_screen_siswa.dart';
import 'package:absensi_siswa/viewmodels/auth_viewmodel.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authVM.isLoggedIn) {
      return const LoginPage();
    }

    // Normalisasi Role
    final String role = authVM.userRole?.toLowerCase() ?? '';

    if (role == 'guru') {
      return const GuruMainPage(); 
    } else if (role == 'siswa') {
      // Langsung return SiswaMainPage karena di dalamnya sudah ada BottomNavBar dan HomeScreenSiswa
      return const SiswaMainPage();
    } else {
      return const Scaffold(
        body: Center(child: Text("Peran pengguna tidak dikenali.")),
      );
    }
  }
}
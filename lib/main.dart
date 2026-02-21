import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/screens/auth_wrapper.dart';
import 'package:absensi_siswa/viewmodels/laporan_viewmodel.dart'; 
import 'package:absensi_siswa/viewmodels/auth_viewmodel.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => KehadiranViewmodel()),
        ChangeNotifierProvider(create: (_) => LaporanViewmodel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Siswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      /// 2. Arahkan home ke AuthWrapper agar pengecekan login berjalan
      home: const AuthWrapper(),
    );
  }
}
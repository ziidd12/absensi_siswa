import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/screens/auth_wrapper.dart';
import 'package:absensi_siswa/viewmodels/laporan_viewmodel.dart'; 
import 'package:absensi_siswa/viewmodels/auth_viewmodel.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:absensi_siswa/viewmodels/assessment_viewmodel.dart'; // TAMBAHKAN
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk mengatur locale default

// Ubah main menjadi async agar bisa menunggu (await) inisialisasi data lokal
void main() async {
  // 1. Wajib ditambahkan agar Flutter Engine siap sebelum proses inisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inisialisasi data format tanggal untuk Indonesia ('id_ID')
    await initializeDateFormatting('id_ID', null);
    
    // 3. Set default locale ke Indonesia agar semua DateFormat otomatis pakai 'id_ID'
    Intl.defaultLocale = 'id_ID';
  } catch (e) {
    debugPrint("Gagal inisialisasi locale: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => KehadiranViewmodel()),
        ChangeNotifierProvider(create: (_) => LaporanViewmodel()),
        ChangeNotifierProvider(create: (_) => AssessmentViewModel()),
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
      // 2. Arahkan home ke AuthWrapper agar pengecekan login berjalan
      home: const AuthWrapper(),
    );
  }
}
import 'package:absensi_siswa/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewModels/auth_viewmodel.dart';
import 'viewModels/kehadiran_viewmodel.dart';

void main() {
  runApp(
    /// 1. Gunakan MultiProvider di tingkat paling atas
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => KehadiranViewmodel()),
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
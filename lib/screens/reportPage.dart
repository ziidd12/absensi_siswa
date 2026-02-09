// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ReportPage extends StatelessWidget {
//   const ReportPage({super.key});

//   Future<void> _exportToExcel(BuildContext context) async {
//     // izin storage
//     await Permission.storage.request();

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel['Report'];

//     // Header
//     sheet.appendRow([
//       TextCellValue("Bulan"),
//       TextCellValue("Kehadiran (%)"),
//     ]);

//     // Data contoh (GANTI DENGAN DATA ASLI NANTI)
//     final data = [
//       ["Januari", 80],
//       ["Februari", 75],
//       ["Maret", 90],
//       ["April", 85],
//     ];

//     for (var row in data) {
//       sheet.appendRow([
//         TextCellValue(row[0].toString()),
//         IntCellValue(row[1] as int),
//       ]);
//     }

//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/report_absensi.xlsx');

//     await file.writeAsBytes(excel.encode()!);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Excel berhasil diexport")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Laporan Absensi")),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.download),
//           label: const Text("Export ke Excel"),
//           onPressed: () => _exportToExcel(context),
//         ),
//       ),
//     );
//   }
// }

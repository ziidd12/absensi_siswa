// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'; // ⬅️ WAJIB
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';

// import 'dart:html' as html; // ⬅️ WEB ONLY (AMAN karena pakai kIsWeb)

// class ReportPage extends StatefulWidget {
//   const ReportPage({super.key});

//   @override
//   State<ReportPage> createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   String selectedTahunAjaran = '2024/2025';
//   String selectedBulan = 'Februari';
//   String selectedKelas = 'X RPL 1';

//   int hadir = 20;
//   int izin = 3;
//   int alfa = 2;
//   int dispensasi = 1;
//   int totalSiswa = 26;

//   Future<void> exportToExcel() async {
//     final excel = Excel.createExcel();
//     final sheet = excel['Laporan Bulanan'];

//     sheet.appendRow([TextCellValue('LAPORAN KEHADIRAN SISWA')]);
//     sheet.appendRow([]);

//     sheet.appendRow([
//       TextCellValue('Tahun Ajaran'),
//       TextCellValue(selectedTahunAjaran),
//     ]);

//     sheet.appendRow([
//       TextCellValue('Bulan'),
//       TextCellValue(selectedBulan),
//     ]);

//     sheet.appendRow([
//       TextCellValue('Kelas'),
//       TextCellValue(selectedKelas),
//     ]);

//     sheet.appendRow([]);

//     sheet.appendRow([
//       TextCellValue('Status'),
//       TextCellValue('Jumlah'),
//     ]);

//     sheet.appendRow([TextCellValue('Hadir'), IntCellValue(hadir)]);
//     sheet.appendRow([TextCellValue('Izin'), IntCellValue(izin)]);
//     sheet.appendRow([TextCellValue('Alfa'), IntCellValue(alfa)]);
//     sheet.appendRow([TextCellValue('Dispen'), IntCellValue(dispensasi)]);
//     sheet.appendRow([TextCellValue('Total'), IntCellValue(totalSiswa)]);

//     final bytes = excel.encode()!;
//     const fileName = 'laporan_absensi.xlsx';

//     // ===== FLUTTER WEB =====
//     if (kIsWeb) {
//       final blob = html.Blob(
//         [Uint8List.fromList(bytes)],
//         'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
//       );

//       final url = html.Url.createObjectUrlFromBlob(blob);
//       html.AnchorElement(href: url)
//         ..setAttribute('download', fileName)
//         ..click();

//       html.Url.revokeObjectUrl(url);
//     }
//     // ===== ANDROID / DESKTOP =====
//     else {
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File('${dir.path}/$fileName');
//       await file.writeAsBytes(bytes);
//     }

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Excel berhasil diunduh')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Laporan Absensi')),
//       body: Center(
//         child: ElevatedButton.icon(
//           onPressed: exportToExcel,
//           icon: const Icon(Icons.download),
//           label: const Text('Download Excel'),
//         ),
//       ),
//     );
//   }
// }

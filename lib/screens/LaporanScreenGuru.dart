import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class GuruReportPage extends StatefulWidget {
  const GuruReportPage({super.key});

  @override
  State<GuruReportPage> createState() => _GuruReportPageState();
}

class _GuruReportPageState extends State<GuruReportPage> {
  String selectedTahun = '2024/2025';
  String selectedBulan = 'Februari';
  String selectedKelas = 'X RPL 1';

  final List<String> tahunList = ['2023/2024', '2024/2025'];
  final List<String> bulanList = ['Januari', 'Februari', 'Maret', 'April'];
  final List<String> kelasList = ['X RPL 1', 'X RPL 2', 'XI RPL 1'];

  final int hadir = 58;
  final int izin = 6;
  final int alfa = 3;
  final int dispensasi = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan Siswa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterCard(),
            const SizedBox(height: 16),
            _chartCard(),
            const SizedBox(height: 20),
            _downloadButton(),
          ],
        ),
      ),
    );
  }

  // ================= FILTER =================
  Widget _filterCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _dropdown('Tahun', tahunList, selectedTahun,
                (v) => setState(() => selectedTahun = v)),
            _dropdown('Bulan', bulanList, selectedBulan,
                (v) => setState(() => selectedBulan = v)),
            _dropdown('Kelas', kelasList, selectedKelas,
                (v) => setState(() => selectedKelas = v)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String value,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 500 ? 200 : double.infinity,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  // ================= CHART =================
  Widget _chartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Rekap Kehadiran ($selectedKelas)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: 70,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: true),
                  barTouchData: BarTouchData(enabled: true),

                  // 🔥 FIX ANGKA KANAN RAPIH
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 36, // ⬅️ KUNCI KERAPIHAN
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Hadir');
                            case 1:
                              return const Text('Izin');
                            case 2:
                              return const Text('Alfa');
                            case 3:
                              return const Text('Disp');
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    _bar(0, hadir, Colors.green),
                    _bar(1, izin, Colors.orange),
                    _bar(2, alfa, Colors.red),
                    _bar(3, dispensasi, Colors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  // ================= DOWNLOAD EXCEL =================
  Widget _downloadButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Download Excel'),
      onPressed: _exportExcel,
    );
  }

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Laporan'];

    sheet.appendRow([
      TextCellValue('Kelas'),
      TextCellValue('Hadir'),
      TextCellValue('Izin'),
      TextCellValue('Alfa'),
      TextCellValue('Dispensasi'),
    ]);

    sheet.appendRow([
      TextCellValue(selectedKelas),
      IntCellValue(hadir),
      IntCellValue(izin),
      IntCellValue(alfa),
      IntCellValue(dispensasi),
    ]);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/laporan_${selectedKelas}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel berhasil diunduh')),
    );
  }
}

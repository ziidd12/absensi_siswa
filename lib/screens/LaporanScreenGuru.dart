import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';

class GuruReportPage extends StatefulWidget {
  const GuruReportPage({super.key});

  @override
  State<GuruReportPage> createState() => _GuruReportPageState();
}

class _GuruReportPageState extends State<GuruReportPage> {
  /// FILTER
  String selectedTahunAjaran = "2024/2025";
  String selectedTahun = "2024";
  String selectedKelas = "XII RPL 1";

  /// DATA REALISTIS
  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun"];

  final int totalSiswa = 34;

  final List<int> hadirPerBulan = [30, 28, 32, 31, 33, 34];

  /// HITUNG PERSENTASE
  double _persentase(int hadir) {
    return (hadir / totalSiswa) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Attendance Report"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FILTER
            Row(
              children: [
                _dropdown(
                  value: selectedTahunAjaran,
                  items: ["2023/2024", "2024/2025"],
                  onChanged: (v) =>
                      setState(() => selectedTahunAjaran = v!),
                ),
                const SizedBox(width: 8),
                _dropdown(
                  value: selectedTahun,
                  items: ["2023", "2024", "2025"],
                  onChanged: (v) => setState(() => selectedTahun = v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _dropdown(
              value: selectedKelas,
              items: ["X RPL 1", "XI RPL 2", "XII RPL 1"],
              onChanged: (v) => setState(() => selectedKelas = v!),
            ),

            const SizedBox(height: 24),

            /// GRAFIK + EXPORT (TENGAH)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 260,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        maxY: 100,
                        barGroups: _barData(),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  Text("${value.toInt()}%"),
                              interval: 20,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text("Export to Excel"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _exportToExcel,
                    ),
                  ),

                  const SizedBox(height: 20), // biar gak nempel navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BAR DATA
  List<BarChartGroupData> _barData() {
    return List.generate(months.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _persentase(hadirPerBulan[index]),
            width: 18,
            borderRadius: BorderRadius.circular(6),
            color: Colors.blue,
          ),
        ],
      );
    });
  }

  /// DROPDOWN
  Widget _dropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// EXPORT EXCEL
  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow([
      TextCellValue("Bulan"),
      TextCellValue("Hadir"),
      TextCellValue("Total Siswa"),
      TextCellValue("Persentase"),
    ]);

    for (int i = 0; i < months.length; i++) {
      sheet.appendRow([
        TextCellValue(months[i]),
        IntCellValue(hadirPerBulan[i]),
        IntCellValue(totalSiswa),
        DoubleCellValue(_persentase(hadirPerBulan[i])),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/attendance_report.xlsx");

    file.writeAsBytesSync(excel.encode()!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel saved: ${file.path}")),
    );
  }
}

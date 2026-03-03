import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:absensi_siswa/viewmodels/laporan_viewmodel.dart';
import 'package:absensi_siswa/models/laporan_model.dart';
import 'dart:typed_data'; 

class Laporanscreenguru extends StatefulWidget {
  const Laporanscreenguru({super.key});

  @override
  State<Laporanscreenguru> createState() => _LaporanscreenguruState();
}

class _LaporanscreenguruState extends State<Laporanscreenguru> {
  // List bantuan untuk UI (Sesuai database/kebutuhan)
  final List<String> tingkatList = ['10', '11', '12'];
  final List<String> jurusanList = ['RPL', 'TKJ', 'MM'];
  final List<String> statusList = ['Hadir', 'Sakit', 'Izin', 'Alpa'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data saat halaman dibuka
    Future.delayed(Duration.zero, () async {
      final vm = context.read<LaporanViewmodel>();
      await vm.initMasterData(); // Ambil daftar Tahun Ajaran dari DB
      await vm.fetchLaporan();    // Ambil data laporan awal
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch viewmodel agar UI reaktif terhadap perubahan state
    final vm = context.watch<LaporanViewmodel>();
    final report = vm.reportData?.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran Realtime'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.fetchLaporan(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _filterCard(vm),
              const SizedBox(height: 16),
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else ...[
                _chartCard(vm),
                const SizedBox(height: 16),
                _attendanceTableCard(report?.absensi ?? []),
                const SizedBox(height: 20),
                _downloadButton(vm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET FILTER (CONNECTED) =================
  Widget _filterCard(LaporanViewmodel vm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Row 1: Tahun Ajaran & Semester (Dinamis dari Database)
            _dropdown('Tahun Ajaran & Semester', 
              vm.listTahunAjaran.map((e) => e['id'].toString()).toList(), 
              vm.selectedTahunAjaranId, 
              (v) {
                vm.selectedTahunAjaranId = v;
                vm.fetchLaporan();
              },
              // Custom label builder agar tampil "2025/2026 (Ganjil)"
              customItems: vm.listTahunAjaran.map((e) => 
                DropdownMenuItem(value: e['id'].toString(), child: Text("${e['tahun']} - ${e['semester']}"))
              ).toList()
            ),
            const SizedBox(height: 12),
            // Row 2: Tingkat & Jurusan
            Row(
              children: [
                Expanded(
                  child: _dropdown('Tingkat', tingkatList, vm.selectedTingkat, (v) {
                    vm.selectedTingkat = v;
                    vm.fetchLaporan();
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown('Jurusan', jurusanList, vm.selectedJurusan, (v) {
                    vm.selectedJurusan = v;
                    vm.fetchLaporan();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 3: Status
            _dropdown('Status (Opsional)', statusList, vm.selectedStatus, (v) {
              vm.selectedStatus = v;
              vm.fetchLaporan();
            }),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, Function(String?) onChanged, {List<DropdownMenuItem<String>>? customItems}) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: customItems ?? items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  // ================= WIDGET CHART (RESPONSIVE PER KELAS) =================
  Widget _chartCard(LaporanViewmodel vm) {
    final classData = vm.perClassStats; // Data hasil olahan ViewModel

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Kehadiran Per Kelas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            if (classData.isEmpty)
              const SizedBox(height: 150, child: Center(child: Text("Tidak ada data untuk grafik")))
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: (classData.values.isEmpty ? 10 : classData.values.reduce((a, b) => a > b ? a : b).toDouble() + 5),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < classData.length) {
                              // Ambil kode kelas (misal '1' dari '12 RPL 1')
                              String name = classData.keys.elementAt(idx).split(' ').last;
                              return Text(name, style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(classData.length, (index) {
                      return _bar(index, classData.values.elementAt(index), Colors.blueAccent);
                    }),
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
          width: 20,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }

  // ================= WIDGET TABEL DENGAN PAGINATION =================
  Widget _attendanceTableCard(List<Absensi> list) {
    final vm = context.read<LaporanViewmodel>();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daftar Detail Absensi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Data Kosong")))
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = list[index];

                  // --- TAMBAHKAN LOGIKA INI DI SINI ---
                  String tampilanJam = "-";
                  try {
                    if (item.waktuScan != null) {
                      // Mengubah string "2024-05-20 08:00:00" menjadi objek DateTime
                      DateTime parseDate = DateTime.parse(item.waktuScan!);
                      // Format menjadi jam:menit (HH:mm)
                      tampilanJam = DateFormat('HH:mm').format(parseDate);
                    }
                  } catch (e) {
                    // Jika format tanggal dari API aneh, tampilkan apa adanya atau "-"
                    tampilanJam = item.waktuScan ?? "-";
                  }
                  // ------------------------------------

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(item.status),
                      child: Text(item.status?[0] ?? '?', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(
                      item.siswa?.namaSiswa ?? 'Tanpa Nama', 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item.siswa?.kelas?.tingkat} ${item.siswa?.kelas?.jurusan} ${item.siswa?.kelas?.nomorKelas ?? ''} | ${item.status}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      tampilanJam, // Sekarang variabel ini sudah terdefinisi di atas
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
              const Divider(),
              // --- TAMPILAN PAGINATION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Halaman ${vm.currentPage} dari ${vm.totalPages}", 
                    style: const TextStyle(fontSize: 12, color: Colors.grey)
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: vm.currentPage > 1 ? () => vm.prevPage() : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Hadir': return Colors.green;
      case 'Sakit': return Colors.orange;
      case 'Izin': return Colors.blue;
      case 'Alpa': return Colors.red;
      default: return Colors.grey;
    }
  }

  // ================= WIDGET DOWNLOAD (CONNECTED) =================
  Widget _downloadButton(LaporanViewmodel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: vm.isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Download Laporan PDF'),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        // Matikan tombol jika sedang loading atau data kosong
        onPressed: (vm.isLoading || vm.reportData == null) ? null : () async {
          try {
            // Tampilkan snackbar loading sederhana
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Menyiapkan PDF..."), duration: Duration(seconds: 1)),
            );

            // PANGGILAN FUNGSI: pastikan nama fungsi persis dengan di ViewModel
            final Uint8List pdfBytes = await vm.downloadLaporanPdf();
            
            await Printing.layoutPdf(
              onLayout: (format) async => pdfBytes,
              name: 'Laporan_Kehadiran_${DateTime.now().millisecondsSinceEpoch}.pdf'
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}
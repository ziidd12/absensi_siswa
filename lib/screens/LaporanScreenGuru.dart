// screens/laporan_screen_guru.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:printing/printing.dart'; // DIHAPUS karena pakai OpenFilex
import 'package:absensi_siswa/viewmodels/laporan_viewmodel.dart';
import 'package:absensi_siswa/models/laporan_model.dart';

class Laporanscreenguru extends StatefulWidget {
  const Laporanscreenguru({super.key});

  @override
  State<Laporanscreenguru> createState() => _LaporanscreenguruState();
}

class _LaporanscreenguruState extends State<Laporanscreenguru> {
  final List<String> statusList = ['Hadir', 'Sakit', 'Izin', 'Alpa'];

  @override
  void initState() {
    super.initState();
    // Memastikan data master diload saat halaman dibuka
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<LaporanViewmodel>().initMasterData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LaporanViewmodel>();
    final report = vm.reportData?.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran Realtime'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: (vm.isLoading && vm.reportData == null)
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: () => vm.fetchLaporan(),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _filterCard(vm),
                        const SizedBox(height: 16),
                        _chartCard(vm),
                        const SizedBox(height: 16),
                        _attendanceTableCard(report?.absensi ?? []),
                        const SizedBox(height: 20),
                        _downloadButton(vm),
                      ],
                    ),
                  ),
                  // Overlay loading agar user tidak klik filter berkali-kali saat proses
                  if (vm.isLoading)
                    Container(
                      color: Colors.white.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
    );
  }

  // ================= WIDGET FILTER =================
  Widget _filterCard(LaporanViewmodel vm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown(
              'Tahun Ajaran', 
              vm.listTahunAjaran.map((e) => e['id'].toString()).toList(), 
              vm.selectedTahunAjaranId, 
              (v) => vm.setTahunAjaran(v),
              customItems: vm.listTahunAjaran.isEmpty 
                  ? [] 
                  : vm.listTahunAjaran.map((e) => 
                      DropdownMenuItem(
                        value: e['id'].toString(), 
                        child: Text("${e['tahun']} - ${e['semester']}")
                      )
                    ).toList(),
              showAllOption: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dropdown('Tingkat', vm.listTingkat, vm.selectedTingkat, (v) => vm.setTingkat(v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdown('Jurusan', vm.listJurusan, vm.selectedJurusan, (v) => vm.setJurusan(v))),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown('Status', statusList, vm.selectedStatus, (v) => vm.setStatus(v)),
          ],
        ),
      ),
    );
  }

  // Helper Dropdown dengan proteksi nilai mismatch (menghindari crash "exactly one item")
  Widget _dropdown(String label, List<String> items, String? value, Function(String?) onChanged, {List<DropdownMenuItem<String>>? customItems, bool showAllOption = true}) {
    String? effectiveValue = value;
    
    // Proteksi: Jika value tidak ada di daftar items, paksa jadi null (pilih "Semua")
    if (customItems != null && customItems.isNotEmpty) {
      if (!customItems.any((item) => item.value == value)) effectiveValue = null;
    } else {
      if (!items.contains(value)) effectiveValue = null;
    }

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        if (showAllOption) const DropdownMenuItem(value: null, child: Text("Semua")),
        if (customItems != null && customItems.isNotEmpty) 
          ...customItems 
        else 
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }

  // ================= WIDGET CHART =================
  Widget _chartCard(LaporanViewmodel vm) {
    final classData = vm.perClassStats;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Kehadiran Per Kelas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                              // Mengambil bagian terakhir kelas (misal dari "12 RPL 1" ambil "1")
                              return Text(classData.keys.elementAt(idx).split(' ').last, style: const TextStyle(fontSize: 10));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(classData.length, (index) => 
                      BarChartGroupData(
                        x: index, 
                        barRods: [
                          BarChartRodData(
                            toY: classData.values.elementAt(index).toDouble(), 
                            color: Colors.blueAccent, 
                            width: 18,
                            borderRadius: BorderRadius.circular(4)
                          )
                        ]
                      )
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET TABLE =================
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
                  String scanJam = "-";
                  try { 
                    if(item.waktuScan != null) {
                      scanJam = DateFormat('HH:mm').format(DateTime.parse(item.waktuScan!)); 
                    }
                  } catch(e) { scanJam = "-"; }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(item.status), 
                      child: Text(item.status?[0] ?? '?', style: const TextStyle(color: Colors.white))
                    ),
                    title: Text(item.siswa?.namaSiswa ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item.siswa?.kelas?.tingkat} ${item.siswa?.kelas?.jurusan} | ${item.status}"),
                    trailing: Text(scanJam, style: const TextStyle(color: Colors.grey)),
                  );
                },
              ),
              const Divider(),
              // Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Halaman ${vm.currentPage} dari ${vm.totalPages}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16), 
                        onPressed: vm.currentPage > 1 ? () => vm.prevPage() : null
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16), 
                        onPressed: vm.currentPage < vm.totalPages ? () => vm.nextPage() : null
                      ),
                    ],
                  )
                ],
              )
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

  // ================= WIDGET DOWNLOAD =================
  Widget _downloadButton(LaporanViewmodel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download_rounded),
        label: vm.isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Download & Buka PDF'),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        // Matikan tombol jika data masih kosong
        onPressed: (vm.isLoading || vm.reportData == null) ? null : () async {
          try {
            // Memberikan feedback loading sederhana
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sedang memproses PDF..."), duration: Duration(seconds: 2)),
            );

            // Memanggil fungsi download di ViewModel
            await vm.downloadAndOpenFile();
            
          } catch (e) {
            if (mounted) {
              // Menampilkan Dialog jika gagal (biasanya karena isi file bukan PDF)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Gagal Membuka PDF"),
                  content: Text(e.toString().contains("PDF") 
                      ? "File yang diterima dari server rusak atau bukan format PDF. Hubungi Admin." 
                      : e.toString()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
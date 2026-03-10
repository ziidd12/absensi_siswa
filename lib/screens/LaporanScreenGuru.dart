import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:absensi_siswa/viewmodels/laporan_viewmodel.dart';
import 'package:absensi_siswa/models/laporan_model.dart';

class Laporanscreenguru extends StatefulWidget {
  const Laporanscreenguru({super.key});

  @override
  State<Laporanscreenguru> createState() => _LaporanscreenguruState();
}

class _LaporanscreenguruState extends State<Laporanscreenguru> {
  // Daftar status lengkap untuk filter
  final List<String> statusList = ['Hadir', 'Terlambat', 'Sakit', 'Izin', 'Dispen', 'Alpa'];

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.grey[100], // Background agak abu supaya Card menonjol
      appBar: AppBar(
        title: const Text('Laporan Kehadiran', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
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
                        const SizedBox(height: 24),
                        _downloadButton(vm),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  if (vm.isLoading)
                    Container(
                      color: Colors.black12,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filter Data", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _dropdown(
              'Tahun Ajaran',
              vm.listTahunAjaran.map((e) => e['id'].toString()).toList(),
              vm.selectedTahunAjaranId,
              (v) => vm.setTahunAjaran(v),
              customItems: vm.listTahunAjaran.isEmpty
                  ? []
                  : vm.listTahunAjaran.map((e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text("${e['tahun']} - ${e['semester']}"))).toList(),
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
            _dropdown('Status Kehadiran', statusList, vm.selectedStatus, (v) => vm.setStatus(v)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, Function(String?) onChanged,
      {List<DropdownMenuItem<String>>? customItems, bool showAllOption = true}) {
    String? effectiveValue = value;
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
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
      items: [
        if (showAllOption) const DropdownMenuItem(value: null, child: Text("Semua Status")),
        if (customItems != null && customItems.isNotEmpty) ...customItems else ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }

  // ================= WIDGET CHART =================
  Widget _chartCard(LaporanViewmodel vm) {
    final classData = vm.perClassStats;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Kehadiran Per Kelas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            if (classData.isEmpty)
              const SizedBox(height: 150, child: Center(child: Text("Data grafik tidak tersedia")))
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(classData.keys.elementAt(idx).split(' ').last, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(classData.length, (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: classData.values.elementAt(index).toDouble(),
                            color: Colors.blueAccent,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ])),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET TABLE (RAPI & MODERN) =================
  Widget _attendanceTableCard(List<Absensi> list) {
    final vm = context.read<LaporanViewmodel>();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Detail Absensi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if(list.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text("${list.length} Siswa", style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(height: 30),
            if (list.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Data tidak ditemukan")))
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = list[index];
                  String scanJam = "--:--";
                  try {
                    if (item.waktuScan != null) {
                      scanJam = DateFormat('HH:mm').format(DateTime.parse(item.waktuScan!));
                    }
                  } catch (e) { scanJam = "--:--"; }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: _getStatusColor(item.status).withOpacity(0.1),
                          child: Text(item.siswa?.namaSiswa?[0].toUpperCase() ?? '?', 
                            style: TextStyle(color: _getStatusColor(item.status), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.siswa?.namaSiswa ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text("${item.siswa?.kelas?.tingkat} ${item.siswa?.kelas?.jurusan}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _statusBadge(item.status ?? '-'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time_filled, size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 4),
                                Text(scanJam, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              _paginationRow(vm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _paginationRow(LaporanViewmodel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Halaman ${vm.currentPage} dari ${vm.totalPages}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        Row(
          children: [
            _pageBtn(Icons.arrow_back_ios_new, vm.currentPage > 1 ? () => vm.prevPage() : null),
            const SizedBox(width: 12),
            _pageBtn(Icons.arrow_forward_ios, vm.currentPage < vm.totalPages ? () => vm.nextPage() : null),
          ],
        )
      ],
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: onTap == null ? Colors.transparent : Colors.blueAccent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 16, color: onTap == null ? Colors.grey[300] : Colors.blueAccent),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Hadir': return Colors.green.shade600;
      case 'Terlambat': return Colors.orange.shade700;
      case 'Sakit': return Colors.blue.shade600;
      case 'Izin': return Colors.amber.shade700;
      case 'Dispen': return Colors.purple.shade600;
      case 'Alpa': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }

  // ================= WIDGET DOWNLOAD =================
  Widget _downloadButton(LaporanViewmodel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: const Text('GENERATE LAPORAN PDF', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2),
        onPressed: (vm.isLoading || vm.reportData == null) ? null : () async {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sedang menyusun dokumen..."), behavior: SnackBarBehavior.floating),
            );
            await vm.downloadAndOpenFile();
          } catch (e) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Gagal"),
                  content: Text(e.toString()),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
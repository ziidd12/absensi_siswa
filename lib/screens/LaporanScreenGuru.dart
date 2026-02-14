import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class GuruReportPage extends StatefulWidget {
  const GuruReportPage({super.key});

  @override
  State<GuruReportPage> createState() => _GuruReportPageState();
}

class _GuruReportPageState extends State<GuruReportPage> {
  String? selectedStatus;
  String? selectedTingkat;
  String? selectedJurusan;

  laporanModel? reportData;
  bool isLoading = false;

  // MASUKKAN TOKEN LOGIN KAMU DI SINI (Dapat dari proses Login)
  final String myToken = "KASIH_TOKEN_KAMU_DISINI";

  final List<String> statusList = ['Hadir', 'Sakit', 'Izin', 'Alpa'];
  final List<String> tingkatList = ['10', '11', '12'];
  final List<String> jurusanList = ['RPL', 'TKJ', 'MM'];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ================= FETCH DATA (URL & AUTH FIXED) =================
  Future<void> fetchData() async {
    setState(() => isLoading = true);

    const String baseUrl = "http://127.0.0.1:8000/api/laporan/kehadiran/pdf";

    try {
      final Uri url = Uri.parse(baseUrl).replace(queryParameters: {
        'format': 'json',
        if (selectedStatus != null) 'status': selectedStatus,
        if (selectedTingkat != null) 'tingkat': selectedTingkat,
        if (selectedJurusan != null) 'jurusan': selectedJurusan,
      });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $myToken', // Tambahan agar tidak Error 401
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          reportData = laporanModel.fromJson(jsonResponse);
        });
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran Realtime'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _filterCard(),
                    const SizedBox(height: 16),
                    _chartCard(),
                    const SizedBox(height: 16),
                    _attendanceTableCard(),
                    const SizedBox(height: 20),
                    _downloadButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // ================= WIDGET FILTER =================
  Widget _filterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _dropdown('Tingkat', tingkatList, selectedTingkat, (v) {
                    setState(() => selectedTingkat = v);
                    fetchData();
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown('Jurusan', jurusanList, selectedJurusan, (v) {
                    setState(() => selectedJurusan = v);
                    fetchData();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown('Status (Opsional)', statusList, selectedStatus, (v) {
              setState(() => selectedStatus = v);
              fetchData();
            }),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ================= WIDGET CHART =================
  Widget _chartCard() {
    final stats = reportData?.data?.statistik;
    int h = stats?.hadir ?? 0;
    int s = stats?.sakit ?? 0;
    int i = stats?.izin ?? 0;
    int a = stats?.alpa ?? 0;

    double maxY = [h, s, i, a]
            .reduce((curr, next) => curr > next ? curr : next)
            .toDouble() + 5;
    if (maxY < 10) maxY = 10;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Grafik Kehadiran Siswa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Hadir');
                            case 1: return const Text('Sakit');
                            case 2: return const Text('Izin');
                            case 3: return const Text('Alpa');
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _bar(0, h, Colors.green),
                    _bar(1, s, Colors.orange),
                    _bar(2, i, Colors.blue),
                    _bar(3, a, Colors.red),
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
          width: 25,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }

  // ================= WIDGET TABEL =================
  Widget _attendanceTableCard() {
    final listAbsensi = reportData?.data?.absensi ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daftar Detail Absensi (${listAbsensi.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            listAbsensi.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("Tidak ada data untuk filter ini")),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listAbsensi.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = listAbsensi[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(item.status),
                          child: Text(item.status?[0] ?? "?",
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(item.siswa?.namaSiswa ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            "${item.siswa?.kelas?.tingkat} ${item.siswa?.kelas?.jurusan} | ${item.sesi?.jadwal?.mapel?.namaMapel ?? ''}"),
                        trailing: Text(item.waktuScan?.substring(0, 5) ?? "-", style: const TextStyle(color: Colors.grey)),
                      );
                    },
                  ),
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
  Widget _downloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Download Laporan PDF'),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () async {
          final Uri url = Uri.parse("http://127.0.0.1:8000/api/laporan/kehadiran/pdf").replace(queryParameters: {
            if (selectedStatus != null) 'status': selectedStatus,
            if (selectedTingkat != null) 'tingkat': selectedTingkat,
            if (selectedJurusan != null) 'jurusan': selectedJurusan,
          });

          await Printing.layoutPdf(
            onLayout: (format) async {
              final response = await http.get(
                url,
                headers: { 'Authorization': 'Bearer $myToken' }
              );
              return response.bodyBytes;
            },
          );
        },
      ),
    );
  }
}

// --- MODEL CLASSES (Tetap sama seperti sebelumnya) ---
class laporanModel {
  bool? success;
  Data? data;
  laporanModel({this.success, this.data});
  laporanModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  Filter? filter;
  Statistik? statistik;
  int? totalData;
  List<Absensi>? absensi;
  Data({this.filter, this.statistik, this.totalData, this.absensi});
  Data.fromJson(Map<String, dynamic> json) {
    filter = json['filter'] != null ? Filter.fromJson(json['filter']) : null;
    statistik = json['statistik'] != null ? Statistik.fromJson(json['statistik']) : null;
    totalData = json['total_data'];
    if (json['absensi'] != null) {
      absensi = <Absensi>[];
      json['absensi'].forEach((v) => absensi!.add(Absensi.fromJson(v)));
    }
  }
}

class Filter {
  int? tingkat;
  String? jurusan;
  String? status;
  Filter({this.tingkat, this.jurusan, this.status});
  Filter.fromJson(Map<String, dynamic> json) {
    tingkat = json['tingkat'];
    jurusan = json['jurusan'];
    status = json['status'];
  }
}

class Statistik {
  int? hadir;
  int? sakit;
  int? izin;
  int? alpa;
  Statistik({this.hadir, this.sakit, this.izin, this.alpa});
  Statistik.fromJson(Map<String, dynamic> json) {
    hadir = json['Hadir'];
    sakit = json['Sakit'];
    izin = json['Izin'];
    alpa = json['Alpa'];
  }
}

class Absensi {
  int? id;
  String? waktuScan;
  String? status;
  Siswa? siswa;
  Sesi? sesi;
  Absensi({this.id, this.waktuScan, this.status, this.siswa, this.sesi});
  Absensi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    waktuScan = json['waktu_scan'];
    status = json['status'];
    siswa = json['siswa'] != null ? Siswa.fromJson(json['siswa']) : null;
    sesi = json['sesi'] != null ? Sesi.fromJson(json['sesi']) : null;
  }
}

class Siswa {
  String? namaSiswa;
  Kelas? kelas;
  Siswa({this.namaSiswa, this.kelas});
  Siswa.fromJson(Map<String, dynamic> json) {
    namaSiswa = json['nama_siswa'];
    kelas = json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null;
  }
}

class Kelas {
  int? tingkat;
  String? jurusan;
  Kelas({this.tingkat, this.jurusan});
  Kelas.fromJson(Map<String, dynamic> json) {
    tingkat = json['tingkat'];
    jurusan = json['jurusan'];
  }
}

class Sesi {
  Jadwal? jadwal;
  Sesi({this.jadwal});
  Sesi.fromJson(Map<String, dynamic> json) {
    jadwal = json['jadwal'] != null ? Jadwal.fromJson(json['jadwal']) : null;
  }
}

class Jadwal {
  Mapel? mapel;
  Jadwal({this.mapel});
  Jadwal.fromJson(Map<String, dynamic> json) {
    mapel = json['mapel'] != null ? Mapel.fromJson(json['mapel']) : null;
  }
}

class Mapel {
  String? namaMapel;
  Mapel({this.namaMapel});
  Mapel.fromJson(Map<String, dynamic> json) {
    namaMapel = json['nama_mapel'];
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi_siswa/viewmodels/kehadiran_viewmodel.dart';
import 'package:absensi_siswa/utils/token_storage.dart';

class AbsensiManualPage extends StatefulWidget {
  final String namaKelas;
  final String mapel;

  const AbsensiManualPage({
    super.key,
    required this.namaKelas,
    required this.mapel,
  });

  @override
  State<AbsensiManualPage> createState() => _AbsensiManualPageState();
}

class _AbsensiManualPageState extends State<AbsensiManualPage> {

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    // Ganti '1' dengan ID jadwal yang sesuai dari menu sebelumnya jika ada
    Future.microtask(() =>
  context.read<KehadiranViewmodel>().fetchSiswaByKelas(widget.namaKelas) // Hapus jadwalId
);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KehadiranViewmodel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.namaKelas, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.mapel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔍 FITUR PENCARIAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (value) => vm.searchSiswa(value),
              decoration: InputDecoration(
                hintText: "Cari nama siswa...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (vm.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.red.shade100,
              width: double.infinity,
              child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
            
          Expanded(
            child: vm.isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : vm.daftarSiswa.isEmpty 
                ? const Center(child: Text("Data tidak ditemukan"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.daftarSiswa.length,
                    itemBuilder: (context, index) {
                      final siswa = vm.daftarSiswa[index];
                      return _buildSiswaCard(siswa, index, vm);
                    },
                  ),
          ),
          _buildBottomAction(vm), 
        ],
      ),
    );
  }

  Widget _buildSiswaCard(Siswa siswa, int index, KehadiranViewmodel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: siswa.isLocked ? Colors.grey.shade50 : Colors.white, // Background beda jika dikunci
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: siswa.isLocked ? Colors.grey.shade200 : Colors.blue.shade50,
            child: Icon(
              siswa.isLocked ? Icons.lock : Icons.person, 
              size: 18, 
              color: siswa.isLocked ? Colors.grey : Colors.blue
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.nama, 
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: siswa.isLocked ? Colors.grey : Colors.black
                  )
                ),
                if (siswa.isLocked)
                  const Text("Sudah diabsen (Terkunci)", style: TextStyle(fontSize: 10, color: Colors.orange)),
              ],
            ),
          ),
          // Tombol status kehadiran (Mati jika isLocked)
          _statusButton("H", Colors.green, siswa.status == 'H', siswa.isLocked ? null : () => vm.updateSiswaStatus(index, 'H')),
          _statusButton("I", Colors.orange, siswa.status == 'I', siswa.isLocked ? null : () => vm.updateSiswaStatus(index, 'I')),
          _statusButton("S", Colors.blue, siswa.status == 'S', siswa.isLocked ? null : () => vm.updateSiswaStatus(index, 'S')),
          _statusButton("A", Colors.red, siswa.status == 'A', siswa.isLocked ? null : () => vm.updateSiswaStatus(index, 'A')),
        ],
      ),
    );
  }

  Widget _statusButton(String label, Color color, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(KehadiranViewmodel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E5EFF),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: vm.isLoading ? null : () async {
          bool sukses = await vm.simpanKehadiran(1); 

          if (!mounted) return;

          if (sukses) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Absensi Berhasil Disimpan!"), backgroundColor: Colors.green)
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(vm.errorMessage ?? "Gagal menyimpan"), backgroundColor: Colors.red)
            );
          }
        },
        child: vm.isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("SIMPAN ABSENSI SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
class RiwayatModel {
  final String hari;
  final List<Pelajaran> daftarPelajaran;

  RiwayatModel({required this.hari, required this.daftarPelajaran});
}

class Pelajaran {
  final String nama;
  final String jam;
  final bool isAbsen; // Ini yang buat warna hijau nanti

  Pelajaran({
    required this.nama, 
    required this.jam, 
    this.isAbsen = false,
  });
}
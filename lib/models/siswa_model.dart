class Siswa {
  final int id;
  final String nama;
  String status; // Hadir, Izin, Sakit, Alpa

  Siswa({required this.id, required this.nama, this.status = 'Belum'});

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      nama: json['nama'],
    );
  }
}
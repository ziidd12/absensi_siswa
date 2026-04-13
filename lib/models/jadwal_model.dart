class JadwalModel {
  final int id;
  final int kelasId;
  final int mapelId;
  final int guruId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final KelasRelasi kelas;
  final MapelRelasi mapel;

  JadwalModel({
    required this.id,
    required this.kelasId,
    required this.mapelId,
    required this.guruId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kelas,
    required this.mapel,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'],
      kelasId: json['kelas_id'],
      mapelId: json['mapel_id'],
      guruId: json['guru_id'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      kelas: KelasRelasi.fromJson(json['kelas']),
      mapel: MapelRelasi.fromJson(json['mapel']),
    );
  }
}

class KelasRelasi {
  final int id;
  final String tingkat;
  final String jurusan;
  final String nomorKelas;

  KelasRelasi({required this.id, required this.tingkat, required this.jurusan, required this.nomorKelas});

  factory KelasRelasi.fromJson(Map<String, dynamic> json) {
    return KelasRelasi(
      id: json['id'],
      tingkat: json['tingkat']?.toString() ?? '', // Tambahkan .toString()
      jurusan: json['jurusan']?.toString() ?? '', // Tambahkan .toString()
      // Error kamu kemungkinan besar di sini karena nomor_kelas sering terbaca int
      nomorKelas: json['nomor_kelas']?.toString() ?? '', 
    );
  }

  String get namaLengkap => "$tingkat $jurusan $nomorKelas";
}

class MapelRelasi {
  final int id;
  final String namaMapel;

  MapelRelasi({required this.id, required this.namaMapel});

  factory MapelRelasi.fromJson(Map<String, dynamic> json) {
    return MapelRelasi(
      id: json['id'],
      namaMapel: json['nama_mapel'] ?? '',
    );
  }
}
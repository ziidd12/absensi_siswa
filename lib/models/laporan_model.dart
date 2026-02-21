class LaporanModel {
  bool? success;
  Data? data;

  LaporanModel({this.success, this.data});

  LaporanModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  Filter? filter;
  Statistik? statistik;
  int? totalData;
  Map<String, int>? statistikGrafik;
  List<Absensi>? absensi;

  Data({this.filter, this.statistik, this.totalData, this.statistikGrafik, this.absensi});

  Data.fromJson(Map<String, dynamic> json) {
    filter = json['filter'] != null ? Filter.fromJson(json['filter']) : null;
    statistik = json['statistik'] != null ? Statistik.fromJson(json['statistik']) : null;
    totalData = json['total_data'];
    
    // FIX: Cek apakah statistik_grafik benar-benar Map atau bukan
    if (json['statistik_grafik'] != null && json['statistik_grafik'] is Map) {
      statistikGrafik = Map<String, int>.from(json['statistik_grafik']);
    } else {
      statistikGrafik = {}; // Jika [], jadikan Map kosong
    }

    if (json['absensi'] != null) {
      absensi = <Absensi>[];
      json['absensi'].forEach((v) { absensi!.add(Absensi.fromJson(v)); });
    }
  }
}

// class Data {
//   Filter? filter;
//   Statistik? statistik;
//   int? totalData;
//   Map<String, int>? statistikGrafik; // Tambahkan ini
//   List<Absensi>? absensi;

//   Data({this.filter, this.statistik, this.totalData, this.statistikGrafik, this.absensi});

//   Data.fromJson(Map<String, dynamic> json) {
//     filter = json['filter'] != null ? Filter.fromJson(json['filter']) : null;
//     statistik = json['statistik'] != null ? Statistik.fromJson(json['statistik']) : null;
//     totalData = json['total_data'];
    
//     // Parsing Map statistik_grafik
//     if (json['statistik_grafik'] != null) {
//       statistikGrafik = Map<String, int>.from(json['statistik_grafik']);
//     }

//     if (json['absensi'] != null) {
//       absensi = <Absensi>[];
//       json['absensi'].forEach((v) { absensi!.add(Absensi.fromJson(v)); });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.filter != null) {
//       data['filter'] = this.filter!.toJson();
//     }
//     if (this.statistik != null) {
//       data['statistik'] = this.statistik!.toJson();
//     }
//     data['total_data'] = this.totalData;
//     if (this.absensi != null) {
//       data['absensi'] = this.absensi!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

class Filter {
  int? tingkat;
  String? jurusan;
  String? status;
  int? tahunAjaranId;

  Filter({this.tingkat, this.jurusan, this.status, this.tahunAjaranId});

  Filter.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN: Gunakan fungsi bantuan untuk mengubah String ke Int jika perlu
    tingkat = _toInt(json['tingkat']);
    jurusan = json['jurusan'];
    status = json['status'];
    tahunAjaranId = _toInt(json['tahun_ajaran_id']);
  }

  // Fungsi pembantu agar tidak error jika API mengirim String
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tingkat'] = tingkat;
    data['jurusan'] = jurusan;
    data['status'] = status;
    data['tahun_ajaran_id'] = tahunAjaranId;
    return data;
  }
}

class Statistik {
  int? hadir;
  int? sakit;
  int? izin;
  int? alpa;

  Statistik({this.hadir, this.sakit, this.izin, this.alpa});

  Statistik.fromJson(Map<String, dynamic> json) {
    hadir = _toInt(json['Hadir']);
    sakit = _toInt(json['Sakit']);
    izin = _toInt(json['Izin']);
    alpa = _toInt(json['Alpa']);
  }

  static int? _toInt(dynamic value) {
    if (value == null) return 0; // Default 0 jika null
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Hadir'] = this.hadir;
    data['Sakit'] = this.sakit;
    data['Izin'] = this.izin;
    data['Alpa'] = this.alpa;
    return data;
  }
}

class Absensi {
  int? id;
  int? siswaId;
  int? sesiId;
  String? waktuScan;
  String? status;
  String? createdAt;
  String? updatedAt;
  Siswa? siswa;
  Sesi? sesi;

  Absensi(
      {this.id,
      this.siswaId,
      this.sesiId,
      this.waktuScan,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.siswa,
      this.sesi});

  Absensi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siswaId = json['siswa_id'];
    sesiId = json['sesi_id'];
    waktuScan = json['waktu_scan'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    siswa = json['siswa'] != null ? new Siswa.fromJson(json['siswa']) : null;
    sesi = json['sesi'] != null ? new Sesi.fromJson(json['sesi']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['siswa_id'] = this.siswaId;
    data['sesi_id'] = this.sesiId;
    data['waktu_scan'] = this.waktuScan;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.siswa != null) {
      data['siswa'] = this.siswa!.toJson();
    }
    if (this.sesi != null) {
      data['sesi'] = this.sesi!.toJson();
    }
    return data;
  }
}

class Siswa {
  int? id;
  int? userId;
  int? idKelas;
  String? namaSiswa;
  String? nIS;
  String? createdAt;
  String? updatedAt;
  Kelas? kelas;

  Siswa(
      {this.id,
      this.userId,
      this.idKelas,
      this.namaSiswa,
      this.nIS,
      this.createdAt,
      this.updatedAt,
      this.kelas});

  Siswa.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    idKelas = json['id_kelas'];
    namaSiswa = json['nama_siswa'];
    nIS = json['NIS'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    kelas = json['kelas'] != null ? new Kelas.fromJson(json['kelas']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['id_kelas'] = this.idKelas;
    data['nama_siswa'] = this.namaSiswa;
    data['NIS'] = this.nIS;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.kelas != null) {
      data['kelas'] = this.kelas!.toJson();
    }
    return data;
  }
}

class Kelas {
  int? id;
  int? tingkat;
  String? jurusan;
  String? nomorKelas;
  String? createdAt;
  String? updatedAt;

  Kelas({this.id, this.tingkat, this.jurusan, this.nomorKelas, this.createdAt, this.updatedAt});

  Kelas.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // PERBAIKAN: Pastikan tingkat aman dari String vs Int
    tingkat = json['tingkat'] is String ? int.tryParse(json['tingkat']) : json['tingkat'];
    jurusan = json['jurusan'];
    nomorKelas = json['nomor_kelas']?.toString(); // Pastikan nomor kelas jadi String
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tingkat'] = tingkat;
    data['jurusan'] = jurusan;
    data['nomor_kelas'] = nomorKelas;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Sesi {
  int? id;
  int? jadwalId;
  String? tanggal;
  String? tokenQr;
  String? createdAt;
  String? updatedAt;
  Jadwal? jadwal;

  Sesi(
      {this.id,
      this.jadwalId,
      this.tanggal,
      this.tokenQr,
      this.createdAt,
      this.updatedAt,
      this.jadwal});

  Sesi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jadwalId = json['jadwal_id'];
    tanggal = json['tanggal'];
    tokenQr = json['token_qr'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    jadwal =
        json['jadwal'] != null ? new Jadwal.fromJson(json['jadwal']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['jadwal_id'] = this.jadwalId;
    data['tanggal'] = this.tanggal;
    data['token_qr'] = this.tokenQr;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.jadwal != null) {
      data['jadwal'] = this.jadwal!.toJson();
    }
    return data;
  }
}

class Jadwal {
  int? id;
  int? kelasId;
  int? mapelId;
  int? guruId;
  String? hari;
  String? jamMulai;
  String? jamSelesai;
  String? createdAt;
  String? updatedAt;
  Mapel? mapel;

  Jadwal(
      {this.id,
      this.kelasId,
      this.mapelId,
      this.guruId,
      this.hari,
      this.jamMulai,
      this.jamSelesai,
      this.createdAt,
      this.updatedAt,
      this.mapel});

  Jadwal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kelasId = json['kelas_id'];
    mapelId = json['mapel_id'];
    guruId = json['guru_id'];
    hari = json['hari'];
    jamMulai = json['jam_mulai'];
    jamSelesai = json['jam_selesai'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    mapel = json['mapel'] != null ? new Mapel.fromJson(json['mapel']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kelas_id'] = this.kelasId;
    data['mapel_id'] = this.mapelId;
    data['guru_id'] = this.guruId;
    data['hari'] = this.hari;
    data['jam_mulai'] = this.jamMulai;
    data['jam_selesai'] = this.jamSelesai;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.mapel != null) {
      data['mapel'] = this.mapel!.toJson();
    }
    return data;
  }
}

class Mapel {
  int? id;
  String? namaMapel;
  String? createdAt;
  String? updatedAt;

  Mapel({this.id, this.namaMapel, this.createdAt, this.updatedAt});

  Mapel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaMapel = json['nama_mapel'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nama_mapel'] = this.namaMapel;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

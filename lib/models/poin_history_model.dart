class PoinHistory {
  final int id;
  final int poinPerubahan;
  final String keterangan;
  final DateTime createdAt;

  PoinHistory({
    required this.id,
    required this.poinPerubahan,
    required this.keterangan,
    required this.createdAt,
  });

  factory PoinHistory.fromJson(Map<String, dynamic> json) {
    return PoinHistory(
      id: json['id'],
      poinPerubahan: json['poin_perubahan'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
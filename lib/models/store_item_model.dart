class StoreItem {
  final int id;
  final String namaItem;
  final int hargaPoin;
  final String icon;
  final String warna;

  StoreItem({
    required this.id,
    required this.namaItem,
    required this.hargaPoin,
    required this.icon,
    required this.warna,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'],
      namaItem: json['nama_item'],
      hargaPoin: json['harga_poin'],
      icon: json['icon'] ?? 'fastfood',
      warna: json['warna'] ?? 'orange',
    );
  }
}
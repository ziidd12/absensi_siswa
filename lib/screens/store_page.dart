import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int saldoPoin = 0;
  bool isLoadingPoin = true;
  bool isLoadingItems = true;
  List<StoreItem> listHadiah = []; // <--- Tempat nyimpen data dari DB

  @override
  void initState() {
    super.initState();
    _loadDataAwal();
  }

  // Fungsi buat sikat semua data sekaligus
  Future<void> _loadDataAwal() async {
    setState(() {
      isLoadingPoin = true;
      isLoadingItems = true;
    });
    
    await _fetchPoinSiswa();
    await _fetchItemsStore();
  }

  // 1. Ambil Poin
  Future<void> _fetchPoinSiswa() async {
    try {
      final poinDariApi = await ApiService.getStorePoints(1); // Ngetes Ahmad Zidan
      setState(() {
        saldoPoin = poinDariApi;
        isLoadingPoin = false;
      });
    } catch (e) {
      setState(() => isLoadingPoin = false);
      print("Gagal ambil poin: $e");
    }
  }

  // 2. Ambil Daftar Hadiah dari Database
  Future<void> _fetchItemsStore() async {
    try {
      final items = await ApiService.getStoreItems();
      setState(() {
        listHadiah = items;
        isLoadingItems = false;
      });
    } catch (e) {
      setState(() => isLoadingItems = false);
      print("Gagal ambil items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Store & Tukar Poin',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDataAwal, // Tarik bawah buat refresh poin & barang
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Saldo Poin
              _buildBalanceCard(),
              
              const SizedBox(height: 25),
              const Text('Item Tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- LOGIKA LIST ITEM DINAMIS ---
              isLoadingItems 
                ? const Center(child: CircularProgressIndicator())
                : listHadiah.isEmpty 
                  ? const Center(child: Text("Belum ada hadiah di database"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listHadiah.length,
                      itemBuilder: (context, index) {
                        final item = listHadiah[index];
                        return _buildStoreItem(
                          item.namaItem, 
                          "${item.hargaPoin} Poin",
                          _getIconData(item.icon), 
                          _getColorData(item.warna)
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Card Saldo
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo Poin Absen',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              isLoadingPoin 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(saldoPoin.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  // Widget Item Store
  Widget _buildStoreItem(String name, String price, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(price, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
        trailing: ElevatedButton(
          onPressed: () {
            // Nanti di sini logika potong poin
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: const StadiumBorder()),
          child: const Text('Tukar', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Helper buat konversi string icon dari DB ke IconData Flutter
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fastfood': return Icons.fastfood_rounded;
      case 'edit': return Icons.edit_note_rounded;
      case 'shirt': return Icons.checkroom_rounded;
      default: return Icons.card_giftcard_rounded;
    }
  }

  // Helper buat konversi string warna dari DB ke Color Flutter
  Color _getColorData(String colorName) {
    switch (colorName) {
      case 'orange': return Colors.orange;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      default: return Colors.blueAccent;
    }
  }
}
import 'package:absensi_siswa/viewModels/history_poin_page.dart';
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
  List<StoreItem> listHadiah = [];

  @override
  void initState() {
    super.initState();
    _loadDataAwal();
  }

  Future<void> _loadDataAwal() async {
    setState(() {
      isLoadingPoin = true;
      isLoadingItems = true;
    });
    
    await _fetchPoinSiswa();
    await _fetchItemsStore();
  }

  // 1. Ambil Poin (ID 1 keur ngetes Ahmad Zidan)
  Future<void> _fetchPoinSiswa() async {
    try {
      final poinDariApi = await ApiService.getPointsStore(); 
      setState(() {
        saldoPoin = poinDariApi;
        isLoadingPoin = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingPoin = false);
      print("❌ Gagal ambil poin: $e");
    }
  }

  Future<void> _fetchItemsStore() async {
    try {
      // Urang pake 'var' heula meh teu lieur tipe datana
      var data = await ApiService.fetchStoreItems(); 
      setState(() {
        listHadiah = data;
        isLoadingItems = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoadingItems = false);
      print("❌ Gagal ambil items: $e");
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
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
  // --- TAMBAHKEUN IEU DI HANDAP ---
  actions: [
    IconButton(
      icon: const Icon(Icons.history, color: Colors.blueAccent),
      onPressed: () {
        // Ieu keur pindah ka halaman riwayat nu geus dijieun tadi
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPoinPage()),
        );
      },
    ),
  ],
),
      body: RefreshIndicator(
        onRefresh: _loadDataAwal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 25),
              const Text('Item Tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              isLoadingItems 
                ? const Center(child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: CircularProgressIndicator(),
                  ))
                : listHadiah.isEmpty 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Belum ada hadiah di database"),
                    ))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listHadiah.length,
                      itemBuilder: (context, index) {
                        final item = listHadiah[index];
                        return _buildStoreItem(item);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

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
                : Text('$saldoPoin Poin',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildStoreItem(StoreItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorData(item.warna).withOpacity(0.1),
          child: Icon(_getIconData(item.icon), color: _getColorData(item.warna)),
        ),
        title: Text(item.namaItem, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item.hargaPoin} Poin", 
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
        trailing: ElevatedButton(
  onPressed: isProcessingRedeem ? null : () => _handleTukar(item),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent, 
    shape: const StadiumBorder()
  ),
  child: isProcessingRedeem 
    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
    : const Text('Tukar', style: TextStyle(color: Colors.white)),
),
      ),
    );
  }

  // Tambahkeun variabel ieu di luhur (di jero State)
bool isProcessingRedeem = false;

void _handleTukar(StoreItem item) async {
  // Mun keur proses, tong dibere asup
  if (isProcessingRedeem) return;

  setState(() => isProcessingRedeem = true);

  try {
    final response = await ApiService.postRedeem(item.id);
    
    // Matikan loading sanggeus dapet jawaban
    setState(() => isProcessingRedeem = false);

    if (response['status'] == 'success') {
      _showSimpleSnackBar(response['message'], Colors.green);
      // Update saldo poin di layar sacara otomatis
      setState(() {
        saldoPoin = response['sisa_poin'];
      });
    } 
    else if (response['status'] == 'has_token') {
      _showSimpleSnackBar(response['message'], Colors.orange);
    } 
    else {
      _showSimpleSnackBar(response['message'], Colors.red);
    }

  } catch (e) {
    setState(() => isProcessingRedeem = false);
    _showSimpleSnackBar("Gagal terhubung ke server. Pastikan koneksi aktif.", Colors.red);
  }
}

// Fungsi Notifikasi nu Sopan
void _showSimpleSnackBar(String pesan, Color warna) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        pesan, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
      ),
      backgroundColor: warna,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}
}

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'fastfood': return Icons.fastfood_rounded;
      case 'edit': return Icons.edit_note_rounded;
      case 'shirt': return Icons.checkroom_rounded;
      default: return Icons.card_giftcard_rounded;
    }
  }

  Color _getColorData(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange': return Colors.orange;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      default: return Colors.blueAccent;
    }
  }
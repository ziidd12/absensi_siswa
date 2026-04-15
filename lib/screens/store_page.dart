import 'package:absensi_siswa/models/poin_history_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:absensi_siswa/viewmodels/gamifikasi_viewmodel.dart';
import 'package:absensi_siswa/models/marketplace_model.dart';
import 'package:absensi_siswa/models/user_token_model.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamifikasiViewModel>().initDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GamifikasiViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dompet Integritas',
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blueAccent,
        onRefresh: () => viewModel.initDashboard(),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _buildHeroSection(viewModel),
              ),
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blueAccent,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: "Riwayat"),
                        Tab(text: "Marketplace"),
                        Tab(text: "Inventory"),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabRiwayat(viewModel.pointHistory),
              _buildTabMarketplace(viewModel.marketplaceItems, viewModel.balance, viewModel),
              _buildTabInventory(viewModel.inventory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(GamifikasiViewModel viewModel) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SALDO POIN PRESTASI',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(
            '${viewModel.balance} Pts',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Level: ${viewModel.userLevel}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB-TAB KONTEN =====================

  // ===================== TAB 1: RIWAYAT MUTASI =====================
  Widget _buildTabRiwayat(List<PointLedger> history) {
    return Builder(builder: (context) {
      return CustomScrollView(
        // key ini penting agar posisi scroll tidak hilang saat pindah tab
        key: const PageStorageKey<String>('riwayat_tab'), 
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          
          if (history.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(Icons.history, "Belum ada riwayat mutasi poin."),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = history[index];
                    
                    // Logic: EARN = Hijau, Selain itu (SPEND/PENALTY) = Merah
                    final bool isEarn = log.transactionType.toUpperCase() == 'EARN';
                    
                    return _buildRiwayatItem(log, isEarn);
                  },
                  childCount: history.length,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildRiwayatItem(PointLedger log, bool isEarn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          // Icon Dinamis
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEarn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn ? Icons.add_rounded : Icons.remove_rounded, 
              color: isEarn ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          // Deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  log.description, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(log.createdAt), 
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                ),
              ]
            ),
          ),
          // Nominal Poin
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarn ? '+' : ''}${log.amount}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15,
                  color: isEarn ? Colors.green : Colors.red
                )
              ),
              const SizedBox(height: 2),
              Text(
                '${log.currentBalance} Pts',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabMarketplace(List<FlexibilityItem> items, int currentBalance, GamifikasiViewModel viewModel) {
    return Builder(builder: (context) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (items.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(Icons.shopping_bag_outlined, "Belum ada item di marketplace."))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMarketItem(items[index], currentBalance, viewModel),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTabInventory(List<UserToken> inventory) {
    return Builder(builder: (context) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (inventory.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(Icons.backpack_outlined, "Kamu belum memiliki token."))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildInventoryItem(inventory[index]),
                  childCount: inventory.length,
                ),
              ),
            ),
        ],
      );
    });
  }

  // ===================== ATOM WIDGETS =====================

  Widget _buildMarketItem(FlexibilityItem item, int balance, GamifikasiViewModel vm) {
    bool canRedeem = balance >= item.pointCost;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: Column(children: [
        Expanded(child: Icon(Icons.confirmation_number_rounded, color: Colors.blueAccent.withOpacity(0.5), size: 40)),
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${item.pointCost} Pts', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, 
                disabledBackgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
            ),
            onPressed: canRedeem && !vm.isLoading ? () => _confirmRedeem(context, item, vm) : null,
            child: vm.isLoading 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Tukar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ))
        ]))
      ]),
    );
  }

  Widget _buildInventoryItem(UserToken token) {
    bool isAvailable = token.status == 'AVAILABLE';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Row(children: [
        Icon(Icons.stars, color: isAvailable ? Colors.amber : Colors.grey),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(token.item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(isAvailable ? 'Status: Aktif' : 'Status: Sudah Digunakan', style: TextStyle(color: isAvailable ? Colors.blue : Colors.grey, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _buildEmptyState(IconData icon, String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 50, color: Colors.grey.shade300),
      const SizedBox(height: 10),
      Text(msg, style: const TextStyle(color: Colors.grey)),
    ]));
  }

  // ===================== LOGIKA KONFIRMASI & REDEEM =====================

  void _confirmRedeem(BuildContext context, FlexibilityItem item, GamifikasiViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: !vm.isLoading, // Jangan biarkan tutup dialog saat loading
      builder: (context) {
        // Kita gunakan StatefulWidget di dalam dialog agar tombol loading bisa update
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Konfirmasi Tukar"),
              content: Text("Tukar ${item.pointCost} poin untuk '${item.itemName}'?"),
              actions: [
                TextButton(
                  onPressed: vm.isLoading ? null : () => Navigator.pop(context), 
                  child: const Text("Batal", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: const StadiumBorder(),
                    elevation: 0
                  ),
                  onPressed: vm.isLoading ? null : () async {
                    // Jalankan redeem
                    bool sukses = await vm.redeemToken(item.id);
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Tutup dialog
                      
                      // Tampilkan Feedback Snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(vm.errorMessage ?? (sukses ? "Berhasil ditukarkan!" : "Gagal")),
                          backgroundColor: sukses ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: vm.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Ya, Tukar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
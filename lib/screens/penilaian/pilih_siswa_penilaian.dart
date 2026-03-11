import 'package:flutter/material.dart';
import 'package:absensi_siswa/service/api_service.dart';
import 'package:absensi_siswa/screens/guru/form_penilaian_screen.dart';
import 'package:absensi_siswa/widgets/loading_widget.dart';
import 'package:absensi_siswa/widgets/error_widget.dart';
import 'package:absensi_siswa/models/teacher_dashboard_model.dart';

class PilihSiswaPenilaianPage extends StatefulWidget {
  const PilihSiswaPenilaianPage({Key? key}) : super(key: key);

  @override
  State<PilihSiswaPenilaianPage> createState() => _PilihSiswaPenilaianPageState();
}

class _PilihSiswaPenilaianPageState extends State<PilihSiswaPenilaianPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<TeacherDashboardViewModel>().loadDashboard()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard Penilaian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0047ff),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<TeacherDashboardViewModel>().refreshData(),
          ),
        ],
      ),
      body: Consumer<TeacherDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.dashboardData == null) {
            return const LoadingWidget();
          }

          if (viewModel.errorMessage != null && viewModel.dashboardData == null) {
            return ErrorDisplayWidget(
              message: viewModel.errorMessage!,
              onRetry: () => viewModel.loadDashboard(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshData(),
            child: CustomScrollView(
              slivers: [
                // Progress Bar Section
                SliverToBoxAdapter(
                  child: _buildProgressCard(viewModel),
                ),

                // Search and Filter Section
                SliverToBoxAdapter(
                  child: _buildSearchAndFilter(viewModel),
                ),

                // Belum Dinilai Section
                if (viewModel.selectedFilter != 'sudah')
                  _buildSiswaSection(
                    title: 'Belum Dinilai',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    siswaList: viewModel.filteredBelumDinilai,
                    isEmpty: viewModel.filteredBelumDinilai.isEmpty &&
                             viewModel.selectedFilter != 'sudah',
                  ),

                // Sudah Dinilai Section
                if (viewModel.selectedFilter != 'belum')
                  _buildSiswaSection(
                    title: 'Sudah Dinilai',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    siswaList: viewModel.filteredSudahDinilai,
                    isEmpty: viewModel.filteredSudahDinilai.isEmpty &&
                             viewModel.selectedFilter != 'belum',
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(TeacherDashboardViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0047ff), Color(0xFF4A7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Penilaian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${viewModel.dinilaiCount} dari ${viewModel.totalSiswa} siswa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${viewModel.progress.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: viewModel.progress / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(TeacherDashboardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama atau NIS...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: viewModel.setSearchQuery,
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 'semua', viewModel),
                _buildFilterChip('Belum Dinilai', 'belum', viewModel),
                _buildFilterChip('Sudah Dinilai', 'sudah', viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, TeacherDashboardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: viewModel.selectedFilter == value,
        onSelected: (_) => viewModel.setFilter(value),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF0047ff).withOpacity(0.1),
        checkmarkColor: const Color(0xFF0047ff),
        labelStyle: TextStyle(
          color: viewModel.selectedFilter == value 
              ? const Color(0xFF0047ff) 
              : Colors.black87,
          fontWeight: viewModel.selectedFilter == value 
              ? FontWeight.bold 
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSiswaSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<SiswaPenilaian> siswaList,
    required bool isEmpty,
  }) {
    if (isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(icon, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada siswa $title',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${siswaList.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...siswaList.map((siswa) => _buildSiswaCard(siswa)),
        ],
      ),
    );
  }

  Widget _buildSiswaCard(SiswaPenilaian siswa) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormPenilaianScreen(
                  siswa: siswa,
                  onSubmitted: () {
                    context.read<TeacherDashboardViewModel>().refreshData();
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Foto/Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: siswa.nilaiTerakhir != null
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  child: siswa.foto != null
                      ? ClipOval(
                          child: Image.network(
                            siswa.foto!,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            errorBuilder: (_, __, ___) => Text(
                              siswa.nama[0].toUpperCase(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : Text(
                          siswa.nama[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            color: siswa.nilaiTerakhir != null
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Info Siswa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NIS: ${siswa.nis}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (siswa.kelas != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                siswa.kelas!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status/Nilai
                Column(
                  children: [
                    if (siswa.nilaiTerakhir != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: siswa.nilaiTerakhir! >= 75
                              ? Colors.green.shade100
                              : siswa.nilaiTerakhir! >= 60
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          siswa.nilaiTerakhir!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: siswa.nilaiTerakhir! >= 75
                                ? Colors.green.shade700
                                : siswa.nilaiTerakhir! >= 60
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Belum',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
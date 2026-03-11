/**
 * Dashboard untuk guru
 */
public function teacherDashboard(Request $request)
{
    $guruId = Auth::id();
    $tahunAjaranId = $this->getActiveYearId($request);
    
    // Cari guru berdasarkan user_id
    $guru = Guru::where('user_id', $guruId)->first();
    
    if (!$guru) {
        return response()->json(['error' => 'Data guru tidak ditemukan'], 404);
    }
    
    // Ambil semua siswa yang diajar guru ini
    $siswaList = Siswa::whereHas('kelas', function($q) use ($guru) {
        $q->where('wali_kelas_id', $guru->id);
    })->with('user')->get();
    
    $totalSiswa = $siswaList->count();
    $dinilaiCount = 0;
    $belumDinilai = [];
    $sudahDinilai = [];
    
    foreach ($siswaList as $siswa) {
        // Cek apakah sudah dinilai di periode ini
        $penilaian = Assessment::where('siswa_id', $siswa->id)
            ->where('evaluator_id', $guruId)
            ->when($tahunAjaranId, function($q) use ($tahunAjaranId) {
                return $q->where('tahun_ajaran_id', $tahunAjaranId);
            })
            ->latest()
            ->first();
        
        $dataSiswa = [
            'id' => $siswa->id,
            'nama' => $siswa->user->name ?? $siswa->nama,
            'nis' => $siswa->nis,
            'kelas' => $siswa->kelas->nama_kelas ?? null,
            'foto' => null, // Bisa ditambahkan jika ada field foto
        ];
        
        if ($penilaian) {
            $dinilaiCount++;
            $dataSiswa['nilai_terakhir'] = $penilaian->details->avg('score');
            $dataSiswa['tanggal_dinilai'] = $penilaian->created_at->format('Y-m-d');
            $sudahDinilai[] = $dataSiswa;
        } else {
            $belumDinilai[] = $dataSiswa;
        }
    }
    
    $progress = $totalSiswa > 0 ? ($dinilaiCount / $totalSiswa) * 100 : 0;
    
    return response()->json([
        'total_siswa' => $totalSiswa,
        'dinilai_count' => $dinilaiCount,
        'progress' => round($progress, 1),
        'belum_dinilai' => $belumDinilai,
        'sudah_dinilai' => $sudahDinilai,
    ]);
}
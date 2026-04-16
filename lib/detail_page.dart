import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';

class DetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> transaksi;

  const DetailPage({super.key, required this.transaksi});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  String mode = 'ringkasan';
  String filter = 'terbaru';
  DateTime selectedMonth = DateTime.now();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        mode = _tabController.index == 0 ? 'ringkasan' : 'tren';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  String getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  bool isSameMonth(DateTime date) {
    return date.month == selectedMonth.month &&
        date.year == selectedMonth.year;
  }

  int totalPengeluaranBulanan() {
    return widget.transaksi
        .where((t) =>
            t['tipe'] == 'pengeluaran' &&
            t['tanggal'] != null &&
            isSameMonth(t['tanggal']))
        .fold(0, (sum, item) => sum + (item['jumlah'] as int));
  }

  int totalPemasukanBulanan() {
    return widget.transaksi
        .where((t) =>
            t['tipe'] == 'saldo' &&
            t['tanggal'] != null &&
            isSameMonth(t['tanggal']))
        .fold(0, (sum, item) => sum + (item['jumlah'] as int));
  }

  List<PieChartSectionData> getPieData() {
    int totalPengeluaran = totalPengeluaranBulanan();
    int totalPemasukan = totalPemasukanBulanan();
    int total = totalPengeluaran + totalPemasukan;

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Kosong',
          radius: 70,
          color: Colors.grey.shade300,
          titleStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        )
      ];
    }

    double persenMasuk = (totalPemasukan / total * 100);
    double persenKeluar = (totalPengeluaran / total * 100);

    return [
      PieChartSectionData(
        value: totalPemasukan.toDouble(),
        title: '${persenMasuk.toStringAsFixed(0)}%',
        radius: 70,
        color: AppTheme.primary,
        titleStyle: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      PieChartSectionData(
        value: totalPengeluaran.toDouble(),
        title: '${persenKeluar.toStringAsFixed(0)}%',
        radius: 70,
        color: AppTheme.danger,
        titleStyle: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }

  List<FlSpot> getLineData() {
    List<Map<String, dynamic>> data = widget.transaksi
        .where((t) =>
            t['tanggal'] != null && isSameMonth(t['tanggal']))
        .toList();

    // urutkan berdasarkan waktu (penting!)
    data.sort((a, b) =>
        (a['tanggal'] as DateTime).compareTo(b['tanggal']));

    List<FlSpot> spots = [];

    double saldo = 0;
    int index = 0;

    for (var t in data) {
      if (t['tipe'] == 'pengeluaran') {
        saldo -= (t['jumlah'] as int);
      } else {
        saldo += (t['jumlah'] as int);
      }

      spots.add(FlSpot(index.toDouble(), saldo));
      index++;
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    return spots;
  }

  // ✅ PERBAIKAN 1: minY sekarang menghitung nilai terkecil (support negatif)
  double _getMinY() {
    final data = getLineData();
    if (data.isEmpty) return 0;

    double min = data.first.y;
    for (var d in data) {
      if (d.y < min) min = d.y;
    }

    // kalau negatif, beri ruang sedikit di bawah
    return min < 0 ? min * 1.2 : 0;
  }

  double _getMaxY() {
    final data = getLineData();
    if (data.isEmpty) return 100;

    double max = data.first.y;
    for (var d in data) {
      if (d.y > max) max = d.y;
    }

    return max * 1.2;
  }

  // ✅ PERBAIKAN 2: pecah spots menjadi segmen-segmen naik/turun
  // Setiap segmen berisi 2 titik berurutan, diberi warna sesuai arahnya.
  List<LineChartBarData> _buildColoredSegments(
      List<FlSpot> spots, bool isDark) {
    if (spots.length < 2) {
      // hanya 1 titik — tampilkan titik saja tanpa garis
      return [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Colors.green,
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: Colors.green,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        )
      ];
    }

    List<LineChartBarData> segments = [];

    for (int i = 0; i < spots.length - 1; i++) {
      final from = spots[i];
      final to = spots[i + 1];

      // naik atau datar = hijau, turun = merah
      final isNaik = to.y >= from.y;
      final segmentColor = isNaik ? Colors.green : Colors.red;

      segments.add(
        LineChartBarData(
          spots: [from, to],
          isCurved: false, // false agar warna tidak "blur" antar segmen
          color: segmentColor,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) {
              // hanya tampilkan dot di titik pertama tiap segmen
              // titik terakhir akan ditangani segmen berikutnya
              return FlDotCirclePainter(
                radius: 4,
                color: segmentColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: segmentColor.withOpacity(0.15),
          ),
        ),
      );
    }

    return segments;
  }

  List<Map<String, dynamic>> getFiltered() {
    List<Map<String, dynamic>> data = widget.transaksi
        .where(
            (t) => t['tanggal'] != null && isSameMonth(t['tanggal']))
        .toList();

    if (filter == 'terlama') {
      return data.reversed.toList();
    } else if (filter == 'terbesar') {
      data.sort(
          (a, b) => (b['jumlah'] as int).compareTo(a['jumlah'] as int));
    } else if (filter == 'terkecil') {
      data.sort(
          (a, b) => (a['jumlah'] as int).compareTo(b['jumlah'] as int));
    }
    return data;
  }

  void nextMonth() => setState(() {
        selectedMonth =
            DateTime(selectedMonth.year, selectedMonth.month + 1);
      });

  void prevMonth() => setState(() {
        selectedMonth =
            DateTime(selectedMonth.year, selectedMonth.month - 1);
      });

  String _formatTanggal(DateTime tgl) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${tgl.day} ${bulan[tgl.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = getFiltered();
    final totalMasuk = totalPemasukanBulanan();
    final totalKeluar = totalPengeluaranBulanan();
    final selisih = totalMasuk - totalKeluar;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) nextMonth();
          else if (details.primaryVelocity! > 0) prevMonth();
        },
        child: SafeArea(
          child: Column(
            children: [
              // APPBAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                  )
                                ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Statistik',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // BULAN NAVIGATOR
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryDark, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: prevMonth,
                                icon: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Text(
                                '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: nextMonth,
                                icon: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // RINGKASAN CARDS
                      Row(
                        children: [
                          _summaryCard(
                            label: 'Pemasukan',
                            amount: totalMasuk,
                            color: AppTheme.primary,
                            icon: Icons.arrow_downward_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            label: 'Pengeluaran',
                            amount: totalKeluar,
                            color: AppTheme.danger,
                            icon: Icons.arrow_upward_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 10),
                          _summaryCard(
                            label: 'Selisih',
                            amount: selisih.abs(),
                            color: selisih >= 0 ? AppTheme.primary : AppTheme.danger,
                            icon: selisih >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // TAB BAR
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFF0FAF4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor:
                              isDark ? Colors.white54 : AppTheme.textMuted,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: 'Nunito',
                          ),
                          tabs: const [
                            Tab(text: 'Ringkasan'),
                            Tab(text: 'Tren'),
                          ],
                          padding: const EdgeInsets.all(4),
                          dividerColor: Colors.transparent,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CHART
                      if (mode == 'ringkasan') ...[
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A2E21)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: getPieData(),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legend('Pemasukan', AppTheme.primary, isDark),
                                  const SizedBox(height: 12),
                                  _legend('Pengeluaran', AppTheme.danger, isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Builder(
                          builder: (context) {
                            final lineData = getLineData();

                            return Container(
                              height: 220,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A2E21)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: lineData.length * 60,
                                  child: LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: (lineData.length - 1).toDouble(),
                                      // ✅ minY sekarang support nilai negatif
                                      minY: _getMinY(),
                                      maxY: _getMaxY(),

                                      gridData: FlGridData(
                                        show: true,
                                        getDrawingHorizontalLine: (_) => FlLine(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.grey.shade100,
                                          strokeWidth: 1,
                                        ),
                                        getDrawingVerticalLine: (_) => FlLine(
                                          color: Colors.transparent,
                                        ),
                                      ),

                                      borderData: FlBorderData(show: false),

                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (val, _) => Text(
                                              val.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark
                                                    ? Colors.white38
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ✅ PERBAIKAN UTAMA: pakai segmen per-titik
                                      lineBarsData: _buildColoredSegments(lineData, isDark),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // FILTER & LIST
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFFF0FAF4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: filter,
                              isDense: true,
                              underline: const SizedBox(),
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.primary, size: 20),
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Nunito',
                              ),
                              dropdownColor: isDark
                                  ? const Color(0xFF1A2E21)
                                  : Colors.white,
                              items: const [
                                DropdownMenuItem(
                                    value: 'terbaru', child: Text('Terbaru')),
                                DropdownMenuItem(
                                    value: 'terlama', child: Text('Terlama')),
                                DropdownMenuItem(
                                    value: 'terbesar', child: Text('Terbesar')),
                                DropdownMenuItem(
                                    value: 'terkecil', child: Text('Terkecil')),
                              ],
                              onChanged: (value) {
                                setState(() => filter = value!);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      data.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 48,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada transaksi bulan ini',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = data[index];
                                final isExpense = item['tipe'] == 'pengeluaran';
                                DateTime tgl = item['tanggal'];

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A2E21)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isExpense
                                              ? AppTheme.danger
                                                  .withOpacity(0.12)
                                              : AppTheme.primary
                                                  .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          isExpense
                                              ? Icons.arrow_upward_rounded
                                              : Icons.arrow_downward_rounded,
                                          color: isExpense
                                              ? AppTheme.danger
                                              : AppTheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['nama'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppTheme.textDark,
                                              ),
                                            ),
                                            Text(
                                              _formatTanggal(tgl),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white38
                                                    : AppTheme.textMuted,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isExpense ? '-' : '+'}Rp ${formatRupiah(item['jumlah'])}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: isExpense
                                              ? AppTheme.danger
                                              : AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E21) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Rp ${formatRupiah(amount)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
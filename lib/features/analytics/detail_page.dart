import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../transaction/transaction_model.dart';

class DetailPage extends StatefulWidget {
  final List<Transaction> transactions;
  const DetailPage({super.key, required this.transactions});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _selectedMonth = DateTime.now();
  int _touchedPieIndex = -1;
  String _historyFilter = 'terbaru';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<Transaction> _monthTransactions() {
    final monthly = widget.transactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();
    monthly.sort((a, b) => a.date.compareTo(b.date));
    return monthly;
  }

  int _totalIncome(List<Transaction> list) =>
      list.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);

  int _totalExpense(List<Transaction> list) =>
      list.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  List<FlSpot> _buildBalanceSpots(List<Transaction> monthly) {
    if (monthly.isEmpty) return [];
    final spots = <FlSpot>[];
    var runningBalance = 0;
    for (var i = 0; i < monthly.length; i++) {
      final transaction = monthly[i];
      runningBalance += transaction.isExpense
          ? -transaction.amount
          : transaction.amount;
      spots.add(FlSpot(i.toDouble(), runningBalance.toDouble()));
    }
    return spots;
  }

  List<PieChartSectionData> _buildPieSections(List<Transaction> monthly) {
    final expenses = monthly.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) return [];

    final Map<TransactionCategory, int> byCategory = {};
    for (final t in expenses) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }

    final total = byCategory.values.fold(0, (s, v) => s + v);
    if (total == 0) return [];

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.asMap().entries.map((entry) {
      final idx = entry.key;
      final cat = entry.value.key;
      final amount = entry.value.value;
      final pct = amount / total;
      final isTouched = idx == _touchedPieIndex;
      return PieChartSectionData(
        color: cat.color,
        value: pct * 100,
        title: isTouched ? '${(pct * 100).toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }

  Map<TransactionCategory, int> _categoryBreakdown(List<Transaction> monthly) {
    final expenses = monthly.where((t) => t.isExpense).toList();
    final Map<TransactionCategory, int> byCategory = {};
    for (final t in expenses) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(
      byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  List<Transaction> _filteredHistory(List<Transaction> monthly) {
    final data = List<Transaction>.from(monthly);

    if (_historyFilter == 'terbaru') {
      data.sort((a, b) => b.date.compareTo(a.date));
      return data;
    }

    if (_historyFilter == 'terlama') {
      data.sort((a, b) => a.date.compareTo(b.date));
      return data;
    }

    if (_historyFilter == 'terbanyak') {
      data.sort((a, b) {
        final amountCompare = b.amount.compareTo(a.amount);
        if (amountCompare != 0) return amountCompare;
        return b.date.compareTo(a.date);
      });
      return data;
    }

    if (_historyFilter == 'paling_sedikit') {
      data.sort((a, b) {
        final amountCompare = a.amount.compareTo(b.amount);
        if (amountCompare != 0) return amountCompare;
        return a.date.compareTo(b.date);
      });
      return data;
    }

    return data;
  }

  int _incomeActivityCount(List<Transaction> monthly) {
    return monthly.where((t) => !t.isExpense).length;
  }

  int _expenseActivityCount(List<Transaction> monthly) {
    return monthly.where((t) => t.isExpense).length;
  }

  List<LineChartBarData> _buildTrendSegments(
    List<Transaction> monthly,
    List<FlSpot> balanceSpots,
    bool isDark,
  ) {
    if (balanceSpots.isEmpty) return const [];

    if (balanceSpots.length == 1) {
      final transaction = monthly.first;
      final color = transaction.isExpense ? AppTheme.danger : AppTheme.primary;
      return [
        LineChartBarData(
          spots: balanceSpots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 4.2,
                color: color,
                strokeWidth: 2,
                strokeColor: isDark ? AppTheme.darkSurface : Colors.white,
              );
            },
          ),
        ),
      ];
    }

    final segments = <LineChartBarData>[];
    for (var i = 1; i < balanceSpots.length; i++) {
      final transaction = monthly[i];
      final color = transaction.isExpense ? AppTheme.danger : AppTheme.primary;
      segments.add(
        LineChartBarData(
          spots: [balanceSpots[i - 1], balanceSpots[i]],
          isCurved: true,
          curveSmoothness: 0.2,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.01),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final isLast = index == 1;
              return FlDotCirclePainter(
                radius: isLast ? 4.2 : 0,
                color: color,
                strokeWidth: isLast ? 2 : 0,
                strokeColor: isDark ? AppTheme.darkSurface : Colors.white,
              );
            },
          ),
        ),
      );
    }
    return segments;
  }

  void _prevMonth() => setState(
    () => _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    ),
  );

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isBefore(DateTime.now().add(const Duration(days: 31)))) {
      setState(() => _selectedMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final mutedColor = isDark ? AppTheme.textLightMuted : AppTheme.textMuted;
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;
    final monthly = _monthTransactions();
    final income = _totalIncome(monthly);
    final expense = _totalExpense(monthly);
    final net = income - expense;
    final balanceSpots = _buildBalanceSpots(monthly);
    final pieSections = _buildPieSections(monthly);
    final breakdown = _categoryBreakdown(monthly);
    final filteredHistory = _filteredHistory(monthly);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Analitik'),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primary,
              unselectedLabelColor: mutedColor,
              indicatorColor: AppTheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Grafik'),
                Tab(text: 'Kategori'),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: textColor,
                  ),
                  Text(
                    formatBulanTahun(_selectedMonth),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.surface(isDark),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: 'Pemasukan',
                        amount: income,
                        color: AppTheme.success,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Pengeluaran',
                        amount: expense,
                        color: AppTheme.danger,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Selisih',
                        amount: net,
                        color: net >= 0 ? AppTheme.success : AppTheme.danger,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_tabCtrl.index),
                child: _tabCtrl.index == 0
                    ? _buildBarChartSection(
                        isDark,
                        surfaceColor,
                        textColor,
                        mutedColor,
                        monthly,
                        balanceSpots,
                      )
                    : _buildCategorySection(
                        isDark,
                        surfaceColor,
                        textColor,
                        mutedColor,
                        pieSections,
                        breakdown,
                        expense,
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildHistorySection(
              isDark,
              textColor,
              mutedColor,
              filteredHistory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color mutedColor,
    List<Transaction> monthly,
    List<FlSpot> balanceSpots,
  ) {
    final chartWidth = (monthly.length * 46.0).clamp(320.0, 2600.0);
    final lineSegments = _buildTrendSegments(monthly, balanceSpots, isDark);
    final incomeCount = _incomeActivityCount(monthly);
    final expenseCount = _expenseActivityCount(monthly);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pergerakan Saldo per Aktivitas',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Grafik naik turun mengikuti urutan jam transaksi.',
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _LegendDot(
                color: AppTheme.primary,
                label: 'Pemasukan',
                value: '$incomeCount aktivitas',
              ),
              _LegendDot(
                color: AppTheme.danger,
                label: 'Pengeluaran',
                value: '$expenseCount aktivitas',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF16323A), Color(0xFF11262D)]
                    : [surfaceColor, const Color(0xFFF6FBFD)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.r2XL),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 0.8,
              ),
              boxShadow: isDark
                  ? []
                  : const [
                      BoxShadow(
                        color: Color(0x12123B52),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
            ),
            child: balanceSpots.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data bulan ini',
                      style: TextStyle(
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: chartWidth,
                      child: RepaintBoundary(
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: monthly.isEmpty
                                ? 0
                                : (monthly.length - 1).toDouble(),
                            minY: _balanceChartMinY(balanceSpots),
                            maxY: _balanceChartMaxY(balanceSpots),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder,
                                strokeWidth: 0.8,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 34,
                                  getTitlesWidget: (v, _) {
                                    final index = v.toInt();
                                    if (index < 0 || index >= monthly.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final step = monthly.length <= 8
                                        ? 1
                                        : (monthly.length / 6).ceil();
                                    if (index % step != 0 &&
                                        index != monthly.length - 1) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        formatWaktu(monthly[index].date),
                                        style: TextStyle(
                                          color: mutedColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: 0,
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.18,
                                  ),
                                  strokeWidth: 1,
                                  dashArray: [5, 4],
                                ),
                              ],
                            ),
                            lineTouchData: LineTouchData(
                              getTouchedSpotIndicator: (barData, spotIndexes) {
                                return spotIndexes.map((spotIndex) {
                                  final transaction = monthly[spotIndex];
                                  final color = transaction.isExpense
                                      ? AppTheme.danger
                                      : AppTheme.primary;
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: color.withValues(alpha: 0.24),
                                      strokeWidth: 1.2,
                                      dashArray: [4, 4],
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, bar, index) {
                                            return FlDotCirclePainter(
                                              radius: 5.5,
                                              color: color,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final transaction = monthly[spot.x.toInt()];
                                    final resultingBalance = spot.y.toInt();
                                    return LineTooltipItem(
                                      '${transaction.name}\n'
                                      '${transaction.isExpense ? '-' : '+'}Rp ${formatRupiah(transaction.amount)}\n'
                                      'Saldo: Rp ${formatRupiah(resultingBalance)}\n'
                                      '${transaction.category.label} • ${formatWaktu(transaction.date)}',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        height: 1.4,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: lineSegments,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _balanceChartMaxY(List<FlSpot> balanceSpots) {
    if (balanceSpots.isEmpty) return 100;
    final maxValue = balanceSpots.map((spot) => spot.y).reduce(math.max);
    return math.max(maxValue * 1.15, 100);
  }

  double _balanceChartMinY(List<FlSpot> balanceSpots) {
    if (balanceSpots.isEmpty) return -100;
    final minValue = balanceSpots.map((spot) => spot.y).reduce(math.min);
    if (minValue >= 0) return 0;
    return minValue * 1.15;
  }

  Widget _buildCategorySection(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color mutedColor,
    List<PieChartSectionData> pieSections,
    Map<TransactionCategory, int> breakdown,
    int totalExpense,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengeluaran per Kategori',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (pieSections.isEmpty)
            Container(
              height: 200,
              decoration: AppTheme.surface(isDark),
              child: Center(
                child: Text(
                  'Tidak ada pengeluaran bulan ini',
                  style: TextStyle(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Container(
              height: 220,
              decoration: AppTheme.surface(isDark),
              child: RepaintBoundary(
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                    centerSpaceRadius: 52,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      touchCallback: (ev, resp) {
                        setState(() {
                          if (!ev.isInterestedForInteractions ||
                              resp == null ||
                              resp.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex =
                              resp.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ...breakdown.entries.map((entry) {
            final cat = entry.key;
            final amount = entry.value;
            final pct = totalExpense > 0 ? amount / totalExpense : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.surface(isDark, radius: AppTheme.rLG),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppTheme.rSM),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat.label,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Rp ${formatCompactAmount(amount)}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: pct.toDouble(),
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cat.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    bool isDark,
    Color textColor,
    Color mutedColor,
    List<Transaction> history,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histori transaksi',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pemasukan dan pengeluaran pada bulan ini.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButton<String>(
                  value: _historyFilter,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                    DropdownMenuItem(value: 'terlama', child: Text('Terlama')),
                    DropdownMenuItem(
                      value: 'terbanyak',
                      child: Text('Terbanyak'),
                    ),
                    DropdownMenuItem(
                      value: 'paling_sedikit',
                      child: Text('Terkecil'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _historyFilter = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: AppTheme.surface(isDark),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, color: mutedColor, size: 38),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada histori transaksi bulan ini',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            ...history.map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HistoryTile(transaction: transaction, isDark: isDark),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });
  final String label;
  final int amount;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.textLightMuted : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Rp ${formatCompactAmount(amount.abs())}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, this.value});
  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.24 : 0.16),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textLightMuted
                        : AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction, required this.isDark});

  final Transaction transaction;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cat = transaction.category;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final mutedColor = isDark ? AppTheme.textLightMuted : AppTheme.textMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.surface(isDark, radius: AppTheme.rXL),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.rMD),
            ),
            child: Icon(cat.icon, color: cat.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cat.label} • ${formatTanggalWaktuSingkat(transaction.date)}',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${transaction.isExpense ? '-' : '+'}Rp ${formatRupiah(transaction.amount)}',
            style: TextStyle(
              color: transaction.isExpense ? AppTheme.danger : AppTheme.success,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

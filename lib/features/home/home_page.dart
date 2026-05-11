import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../analytics/detail_page.dart';
import '../profile/profile_page.dart';
import '../transaction/transaction_model.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  const HomePage({super.key, this.onToggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int saldo = 0;
  int totalPemasukan = 0;
  int totalPengeluaran = 0;
  String username = 'Pengguna';
  List<Transaction> transactions = [];

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadData();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    saldo = 0;
    totalPemasukan = 0;
    totalPengeluaran = 0;
    for (final t in transactions) {
      if (t.isExpense) {
        totalPengeluaran += t.amount;
        saldo -= t.amount;
      } else {
        totalPemasukan += t.amount;
        saldo += t.amount;
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transaksi', encoded);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transaksi');
    if (!mounted) return;
    setState(() {
      username = prefs.getString('username') ?? 'Pengguna';
      if (data != null) {
        final decoded = jsonDecode(data) as List<dynamic>;
        transactions =
            decoded
                .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        transactions = [];
      }
      _recalculate();
    });
    _heroCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _listCtrl.forward();
  }

  Map<String, List<Transaction>> _groupedTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<Transaction>>{};
    for (final t in transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      String key;
      if (d == today) {
        key = 'Hari ini';
      } else if (d == yesterday) {
        key = 'Kemarin';
      } else {
        key = formatTanggalSingkat(t.date);
      }
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  void _showAddSheet({required bool isExpense}) {
    HapticFeedback.lightImpact();
    final namaCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController();
    TransactionCategory selectedCategory = isExpense
        ? TransactionCategory.food
        : TransactionCategory.income;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final bg = isDark ? AppTheme.darkSurface : Colors.white;
          final textColor = isDark ? Colors.white : AppTheme.textDark;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.r2XL),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFDDE6EB),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  (isExpense
                                          ? AppTheme.danger
                                          : AppTheme.primary)
                                      .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppTheme.rMD),
                            ),
                            child: Icon(
                              isExpense
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: isExpense
                                  ? AppTheme.danger
                                  : AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isExpense
                                    ? 'Catat Pengeluaran'
                                    : 'Catat Pemasukan',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                isExpense
                                    ? 'Berapa yang kamu keluarkan?'
                                    : 'Berapa yang kamu terima?',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.textLightMuted
                                      : AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceHigh
                              : AppTheme.lightBg,
                          borderRadius: BorderRadius.circular(AppTheme.rLG),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: TextField(
                          controller: jumlahCtrl,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.textLightMuted
                                  : AppTheme.textMuted,
                            ),
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : const Color(0xFFCBD9E0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.rLG),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            filled: false,
                          ),
                          onChanged: (v) {
                            if (v.isEmpty) return;
                            final n = int.tryParse(v.replaceAll('.', '')) ?? 0;
                            final f = formatRupiah(n);
                            jumlahCtrl.value = TextEditingValue(
                              text: f,
                              selection: TextSelection.collapsed(
                                offset: f.length,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (isExpense) ...[
                        TextField(
                          controller: namaCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Keterangan (opsional)',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (isExpense) ...[
                        SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: TransactionCategory.values
                                .where((c) => c != TransactionCategory.income)
                                .map((cat) {
                                  final selected = cat == selectedCategory;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setSheet(() => selectedCategory = cat);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? cat.color.withOpacity(0.15)
                                            : (isDark
                                                  ? AppTheme.darkSurfaceHigh
                                                  : AppTheme.lightBg),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.rSM,
                                        ),
                                        border: Border.all(
                                          color: selected
                                              ? cat.color
                                              : (isDark
                                                    ? AppTheme.darkBorder
                                                    : AppTheme.lightBorder),
                                          width: selected ? 1.4 : 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            cat.icon,
                                            size: 16,
                                            color: cat.color,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            cat.label,
                                            style: TextStyle(
                                              color: selected
                                                  ? cat.color
                                                  : (isDark
                                                        ? AppTheme
                                                              .textLightMuted
                                                        : AppTheme.textMuted),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      _DateSelector(
                        isDark: isDark,
                        selectedDate: selectedDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setSheet(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExpense ? AppTheme.danger : null,
                            foregroundColor: isExpense ? Colors.white : null,
                          ),
                          onPressed: () {
                            final raw = jumlahCtrl.text.replaceAll('.', '');
                            final jml = int.tryParse(raw) ?? 0;
                            if (jml == 0) {
                              HapticFeedback.heavyImpact();
                              return;
                            }
                            final txn = Transaction(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: isExpense
                                  ? (namaCtrl.text.isEmpty
                                        ? selectedCategory.label
                                        : namaCtrl.text)
                                  : 'Pemasukan',
                              amount: jml,
                              isExpense: isExpense,
                              date: selectedDate,
                              category: isExpense
                                  ? selectedCategory
                                  : TransactionCategory.income,
                            );
                            HapticFeedback.mediumImpact();
                            setState(() {
                              transactions.insert(0, txn);
                              transactions.sort(
                                (a, b) => b.date.compareTo(a.date),
                              );
                              _recalculate();
                            });
                            _saveData();
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isExpense
                                      ? '${txn.name} — Rp ${formatRupiah(jml)}'
                                      : 'Pemasukan Rp ${formatRupiah(jml)} dicatat',
                                ),
                                backgroundColor: isExpense
                                    ? AppTheme.danger
                                    : AppTheme.primaryDark,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            isExpense
                                ? 'Simpan Pengeluaran'
                                : 'Simpan Pemasukan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final mutedColor = isDark ? AppTheme.textLightMuted : AppTheme.textMuted;
    final grouped = _groupedTransactions();
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _heroFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                  child: RepaintBoundary(
                    child: _HeroCard(
                      isDark: isDark,
                      greeting: _greeting(),
                      username: username,
                      saldo: saldo,
                      totalPemasukan: totalPemasukan,
                      totalPengeluaran: totalPengeluaran,
                      onProfileTap: () => Navigator.push(
                        context,
                        _fadeRoute(
                          ProfilePage(onToggleTheme: widget.onToggleTheme),
                        ),
                      ).then((_) => _loadData()),
                      onAnalyticsTap: () => Navigator.push(
                        context,
                        _fadeRoute(DetailPage(transactions: transactions)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          '${transactions.length} transaksi tercatat',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (transactions.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          _fadeRoute(DetailPage(transactions: transactions)),
                        ),
                        child: const Text('Lihat semua →'),
                      ),
                  ],
                ),
              ),
            ),
            if (transactions.isEmpty)
              SliverFillRemaining(child: _EmptyState(isDark: isDark))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      int cursor = 0;
                      for (final key in groupKeys) {
                        final items = grouped[key]!;
                        if (i == cursor) {
                          return _DateHeader(label: key, isDark: isDark);
                        }
                        cursor++;
                        for (int j = 0; j < items.length; j++) {
                          if (i == cursor) {
                            final capturedCursor = cursor;
                            return AnimatedBuilder(
                              animation: _listCtrl,
                              builder: (_, child) => FadeTransition(
                                opacity: Tween<double>(begin: 0, end: 1)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _listCtrl,
                                        curve: Interval(
                                          math.min(capturedCursor * 0.03, 0.8),
                                          1.0,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                child: child,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Dismissible(
                                  key: Key(items[j].id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.rXL,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_rounded,
                                      color: AppTheme.danger,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      transactions.remove(items[j]);
                                      _recalculate();
                                    });
                                    _saveData();
                                  },
                                  child: _TransactionTile(
                                    transaction: items[j],
                                    isDark: isDark,
                                    isLast: j == items.length - 1,
                                  ),
                                ),
                              ),
                            );
                          }
                          cursor++;
                        }
                      }
                      return null;
                    },
                    childCount: grouped.values.fold(
                      0,
                      (sum, list) => (sum ?? 0) + list.length + 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        isDark: isDark,
        onAddExpense: () => _showAddSheet(isExpense: true),
        onAddIncome: () => _showAddSheet(isExpense: false),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isDark,
    required this.greeting,
    required this.username,
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.onProfileTap,
    required this.onAnalyticsTap,
  });

  final bool isDark;
  final String greeting;
  final String username;
  final int saldo;
  final int totalPemasukan;
  final int totalPengeluaran;
  final VoidCallback onProfileTap;
  final VoidCallback onAnalyticsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.heroGradient(isDark),
        ),
        borderRadius: BorderRadius.circular(AppTheme.r2XL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: _Avatar(username: username),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Color(0xB8FFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _HeroIconBtn(
                icon: Icons.bar_chart_rounded,
                onTap: onAnalyticsTap,
                tooltip: 'Analitik',
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Total Saldo',
            style: TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              'Rp ${formatRupiah(saldo)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Pemasukan',
                  amount: totalPemasukan,
                  isIncome: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Pengeluaran',
                  amount: totalPengeluaran,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.username});
  final String username;

  String get _initials {
    final clean = username.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.rMD),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _HeroIconBtn extends StatelessWidget {
  const _HeroIconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.rSM),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.isIncome,
  });
  final String label;
  final int amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.rLG),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(AppTheme.rXS),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isIncome
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFFFD1D1),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Rp ${formatCompactAmount(amount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? AppTheme.textLightMuted : AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.isDark,
    required this.isLast,
  });
  final Transaction transaction;
  final bool isDark;
  final bool isLast;

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.12),
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
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${cat.label} • ${formatWaktu(transaction.date)}',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isExpense ? '−' : '+'}Rp ${formatCompactAmount(transaction.amount)}',
            style: TextStyle(
              color: transaction.isExpense ? AppTheme.danger : AppTheme.success,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isDark,
    required this.onAddExpense,
    required this.onAddIncome,
  });
  final bool isDark;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: '+ Pengeluaran',
                color: AppTheme.danger,
                isDark: isDark,
                onTap: onAddExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: '+ Pemasukan',
                color: AppTheme.primary,
                isDark: isDark,
                onTap: onAddIncome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppTheme.rLG),
          border: Border.all(color: color.withOpacity(0.25), width: 0.8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.isDark,
    required this.selectedDate,
    required this.onTap,
  });
  final bool isDark;
  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceHigh : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(AppTheme.rLG),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              formatTanggalSingkat(selectedDate),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const Text(
              'Ubah',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0x1A0F9D7A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 38,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Mulai catat pemasukan atau pengeluaranmu hari ini.',
              style: TextStyle(
                color: isDark ? AppTheme.textLightMuted : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

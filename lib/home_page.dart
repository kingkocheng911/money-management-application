import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'detail_page.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int saldo = 0;
  int totalPemasukan = 0;
  int totalPengeluaran = 0;

  List<Map<String, dynamic>> transaksi = [];

  late AnimationController _headerController;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerAnim =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic);
    loadData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  void _recalculate() {
    saldo = 0;
    totalPemasukan = 0;
    totalPengeluaran = 0;
    for (var t in transaksi) {
      if (t['tipe'] == 'pengeluaran') {
        totalPengeluaran += t['jumlah'] as int;
        saldo -= t['jumlah'] as int;
      } else {
        totalPemasukan += t['jumlah'] as int;
        saldo += t['jumlah'] as int;
      }
    }
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = transaksi.map((e) => {
          ...e,
          'tanggal': (e['tanggal'] as DateTime).toIso8601String(),
        }).toList();
    prefs.setString('transaksi', jsonEncode(encoded));
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('transaksi');

    if (data != null) {
      List decoded = jsonDecode(data);
      setState(() {
        transaksi = decoded.map((e) {
  return {
    'nama': e['nama'],
    'jumlah': e['jumlah'],
    'tipe': e['tipe'],
    'tanggal': DateTime.parse(e['tanggal']),
  };
}).toList();

// 🔥 SORT SETELAH MAP (INI YANG BENAR)
transaksi.sort((a, b) =>
    (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime));
        _recalculate();
      });
    } else {
      _dummyData();
    }

    _headerController.forward();
  }

  void _dummyData() {
    setState(() {
      transaksi = [
        
        {
          'nama': 'Gaji Bulanan',
          'jumlah': 2000000,
          'tipe': 'saldo',
          'tanggal': DateTime.now().subtract(const Duration(days: 10)),
        },
        {
          'nama': 'Bonus',
          'jumlah': 500000,
          'tipe': 'saldo',
          'tanggal': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'nama': 'Makan Siang',
          'jumlah': 25000,
          'tipe': 'pengeluaran',
          'tanggal': DateTime.now(),
        },
        {
          'nama': 'Ngopi',
          'jumlah': 18000,
          'tipe': 'pengeluaran',
          'tanggal': DateTime.now(),
        },
        {
          'nama': 'Transport',
          'jumlah': 15000,
          'tipe': 'pengeluaran',
          'tanggal': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'nama': 'Pulsa',
          'jumlah': 50000,
          'tipe': 'pengeluaran',
          'tanggal': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'nama': 'Belanja',
          'jumlah': 120000,
          'tipe': 'pengeluaran',
          'tanggal': DateTime.now().subtract(const Duration(days: 3)),
        },
      ];
      _recalculate();
      transaksi.sort((a, b) =>
  (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime));
    });
    saveData();
  }

  void _showAddTransaction() {
    final namaCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController();
    String tipe = 'pengeluaran';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2E21) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white24
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Tambah Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TOGGLE TIPE
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFF0FAF4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _toggleBtn(
                            label: '💸 Pengeluaran',
                            selected: tipe == 'pengeluaran',
                            color: AppTheme.danger,
                            onTap: () => setModal(() => tipe = 'pengeluaran'),
                            isDark: isDark,
                          ),
                          _toggleBtn(
                            label: '💰 Pemasukan',
                            selected: tipe == 'saldo',
                            color: AppTheme.primary,
                            onTap: () => setModal(() => tipe = 'saldo'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (tipe == 'pengeluaran') ...[
                      TextField(
                        controller: namaCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nama transaksi',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: jumlahCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Jumlah (Rp)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        int number = int.parse(value.replaceAll('.', ''));
                        String formatted = formatRupiah(number);
                        jumlahCtrl.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // DATE ROW
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModal(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFF0FAF4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Ganti',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          int jml = int.tryParse(
                                  jumlahCtrl.text.replaceAll('.', '')) ??
                              0;
                          if (jml == 0) return;

                          setState(() {
                            transaksi.insert(0, {
                              'nama': tipe == 'pengeluaran'
                                  ? (namaCtrl.text.isEmpty
                                      ? 'Pengeluaran'
                                      : namaCtrl.text)
                                  : 'Pemasukan',
                              'jumlah': jml,
                              'tipe': tipe,
                              'tanggal': selectedDate,
                            });
                            transaksi.sort((a, b) =>
  (b['tanggal'] as DateTime).compareTo(a['tanggal'] as DateTime));
                            _recalculate();
                          });

                          saveData();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tipe == 'pengeluaran'
                                  ? 'Pengeluaran ditambahkan 📝'
                                  : 'Pemasukan ditambahkan 💰'),
                              backgroundColor: tipe == 'pengeluaran'
                                  ? AppTheme.danger
                                  : AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tipe == 'pengeluaran'
                              ? AppTheme.danger
                              : AppTheme.primary,
                        ),
                        child: Text(
                          tipe == 'pengeluaran' ? 'Catat Pengeluaran' : 'Catat Pemasukan',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.grey),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  String _formatTanggal(DateTime tgl) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${tgl.day} ${bulan[tgl.month - 1]}';
  }

  IconData _getIcon(String nama) {
    nama = nama.toLowerCase();
    if (nama.contains('makan') || nama.contains('food')) {
      return Icons.restaurant_rounded;
    } else if (nama.contains('transport') || nama.contains('grab') || nama.contains('gojek')) {
      return Icons.directions_car_rounded;
    } else if (nama.contains('kopi') || nama.contains('ngopi') || nama.contains('cafe')) {
      return Icons.coffee_rounded;
    } else if (nama.contains('belanja') || nama.contains('shop')) {
      return Icons.shopping_bag_rounded;
    } else if (nama.contains('pulsa') || nama.contains('internet')) {
      return Icons.wifi_rounded;
    } else if (nama.contains('laundry')) {
      return Icons.local_laundry_service_rounded;
    } else if (nama.contains('gaji') || nama.contains('bonus')) {
      return Icons.account_balance_rounded;
    }
    return Icons.receipt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1F17) : const Color(0xFFF8FFF9),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ========== HEADER ==========
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryDark,
                      AppTheme.primary,
                      AppTheme.accent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfilePage()),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
                                      'Pengguna',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _iconBtn(
                                icon: Icons.bar_chart_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailPage(transaksi: transaksi),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _iconBtn(
                                icon: Icons.settings_rounded,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsPage()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // SALDO UTAMA
                      AnimatedBuilder(
                        animation: _headerAnim,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _headerAnim.value,
                            child: child,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Saldo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${formatRupiah(saldo)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PEMASUKAN & PENGELUARAN
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.arrow_downward_rounded,
                              label: 'Pemasukan',
                              amount: totalPemasukan,
                              color: Colors.white,
                              bgColor: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.arrow_upward_rounded,
                              label: 'Pengeluaran',
                              amount: totalPengeluaran,
                              color: const Color(0xFFFFD6D6),
                              bgColor: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ========== RIWAYAT ==========
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailPage(transaksi: transaksi),
                              ),
                            ),
                            child: Text(
                              'Lihat semua',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: transaksi.isEmpty
                            ? _emptyState(isDark)
                            : ListView.separated(
                                itemCount: transaksi.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final data = transaksi[index];
                                  final isExpense =
                                      data['tipe'] == 'pengeluaran';
                                  DateTime tgl = data['tanggal'];

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1A2E21)
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.04),
                                                blurRadius: 12,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
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
                                            _getIcon(data['nama']),
                                            color: isExpense
                                                ? AppTheme.danger
                                                : AppTheme.primary,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['nama'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppTheme.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
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
                                          '${isExpense ? '-' : '+'}Rp ${formatRupiah(data['jumlah'])}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.accent],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddTransaction,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required int amount,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${formatRupiah(amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tekan + untuk menambahkan',
            style: TextStyle(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

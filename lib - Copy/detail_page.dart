import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> transaksi;

  const DetailPage({super.key, required this.transaksi});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  String mode = "ringkasan";
  String filter = "terbaru";

  DateTime selectedMonth = DateTime.now();

  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String getMonthName(int month) {
    const months = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return months[month - 1];
  }

  // 🔥 FILTER BULAN
  bool isSameMonth(DateTime date) {
    return date.month == selectedMonth.month &&
        date.year == selectedMonth.year;
  }

  // TOTAL BULAN
  int totalBulanan() {
    return widget.transaksi
        .where((t) =>
            t['tipe'] == "pengeluaran" &&
            t['tanggal'] != null &&
            isSameMonth(t['tanggal']))
        .fold(0, (sum, item) => sum + (item['jumlah'] as int));
  }

  // PIE
  List<PieChartSectionData> getPieData() {
  int totalPengeluaran = 0;
  int totalPemasukan = 0;

  for (var t in widget.transaksi) {
    if (t['tanggal'] == null) continue;
    if (!isSameMonth(t['tanggal'])) continue;

    if (t['tipe'] == "pengeluaran") {
      totalPengeluaran += (t['jumlah'] as int);
    } else {
      totalPemasukan += (t['jumlah'] as int);
    }
  }

  int total = totalPengeluaran + totalPemasukan;

  if (total == 0) {
    return [
      PieChartSectionData(
        value: 1,
        title: "0",
        radius: 60,
      )
    ];
  }

  return [
    PieChartSectionData(
      value: totalPemasukan.toDouble(),
      title: "Masuk",
      radius: 60,
      color: Colors.green,
    ),
    PieChartSectionData(
      value: totalPengeluaran.toDouble(),
      title: "Keluar",
      radius: 60,
      color: Colors.red,
    ),
  ];
}

  // LINE
  List<FlSpot> getLineData() {
    Map<int, int> perHari = {};

    for (var t in widget.transaksi) {
      if (t['tipe'] != "pengeluaran") continue;
      if (t['tanggal'] == null) continue;
      if (!isSameMonth(t['tanggal'])) continue;

      int day = t['tanggal'].day;

      perHari[day] = (perHari[day] ?? 0) + (t['jumlah'] as int);
    }

    List<FlSpot> spots = [];

    perHari.forEach((day, total) {
      spots.add(FlSpot(day.toDouble(), total.toDouble()));
    });

    spots.sort((a, b) => a.x.compareTo(b.x));

    return spots;
  }

  // FILTER LIST
  List<Map<String, dynamic>> getFiltered() {
    List<Map<String, dynamic>> data = widget.transaksi
        .where((t) => t['tanggal'] != null && isSameMonth(t['tanggal']))
        .toList();

    if (filter == "terlama") {
      return data.reversed.toList();
    } else if (filter == "terbesar") {
      data.sort((a, b) => (b['jumlah'] as int).compareTo(a['jumlah'] as int));
    } else if (filter == "terkecil") {
      data.sort((a, b) => (a['jumlah'] as int).compareTo(b['jumlah'] as int));
    }

    return data;
  }

  void nextMonth() {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
      );
    });
  }

  void prevMonth() {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
      );
    });
  }

  BoxDecoration boxStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = getFiltered();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Statistik"),
      ),
      body: GestureDetector(

        // 🔥 SWIPE
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            nextMonth(); // swipe kiri
          } else if (details.primaryVelocity! > 0) {
            prevMonth(); // swipe kanan
          }
        },

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 🔥 HEADER BULAN
              Container(
                padding: const EdgeInsets.all(10),
                decoration: boxStyle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: prevMonth,
                      icon: const Icon(Icons.arrow_left),
                    ),
                    Text(
                      "${getMonthName(selectedMonth.month)} ${selectedMonth.year}",
                    ),
                    IconButton(
                      onPressed: nextMonth,
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // MODE
              Container(
                decoration: boxStyle(),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            mode = "ringkasan";
                          });
                        },
                        child: const Text("Ringkasan"),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            mode = "tren";
                          });
                        },
                        child: const Text("Tren"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // CHART
              if (mode == "ringkasan") ...[
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: boxStyle(),
                  child: PieChart(
                    PieChartData(
                      sections: getPieData(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Total: Rp ${formatRupiah(totalBulanan())}"),
              ] else ...[
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(10),
                  decoration: boxStyle(),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: getLineData(),
                          isCurved: true,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                        )
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // FILTER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: boxStyle(),
                child: DropdownButton<String>(
                  value: filter,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "terbaru", child: Text("Terbaru")),
                    DropdownMenuItem(value: "terlama", child: Text("Terlama")),
                    DropdownMenuItem(value: "terbesar", child: Text("Terbesar")),
                    DropdownMenuItem(value: "terkecil", child: Text("Terkecil")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filter = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // LIST
              Expanded(
                child: Container(
                  decoration: boxStyle(),
                  child: data.isEmpty
                      ? const Center(child: Text("Tidak ada data"))
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            DateTime tgl = item['tanggal'];

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(item['nama']),
                                  subtitle: Text(
                                    "${tgl.day}/${tgl.month}/${tgl.year} - Rp ${formatRupiah(item['jumlah'])}",
                                  ),
                                ),
                                const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // TEMA WARNA
  static const Color primary = Color(0xFF6B8E6E);
  static const Color background = Color(0xFFF5F1E8);
  static const Color textColor = Color(0xFF333333);
  static const Color accent1 = Color(0xFF2F5D50);
  static const Color accent2 = Color(0xFFB85450);

  int saldo = 1000000;
  int pengeluaran = 0;

  List<Map<String, dynamic>> transaksi = [];

  // FORMAT RUPIAH
  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // POPUP INPUT
  void showPopup() {
    TextEditingController nama = TextEditingController();
    TextEditingController jumlah = TextEditingController();

    String tipe = "pengeluaran";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Tambah Data",
                style: TextStyle(color: textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // SWITCH
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                tipe = "pengeluaran";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: tipe == "pengeluaran"
                                    ? accent2
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Pengeluaran",
                                  style: TextStyle(
                                    color: tipe == "pengeluaran"
                                        ? Colors.white
                                        : textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                tipe = "saldo";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: tipe == "saldo"
                                    ? primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Saldo",
                                  style: TextStyle(
                                    color: tipe == "saldo"
                                        ? Colors.white
                                        : textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // INPUT NAMA
                  if (tipe == "pengeluaran")
                    TextField(
                      controller: nama,
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Nama Transaksi",
                        labelStyle: const TextStyle(color: primary),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: accent1),
                        ),
                      ),
                    ),

                  if (tipe == "pengeluaran")
                    const SizedBox(height: 10),

                  // INPUT JUMLAH (AUTO TITIK)
                  TextField(
                    controller: jumlah,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Jumlah",
                      labelStyle: const TextStyle(color: primary),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: accent1),
                      ),
                    ),
                    onChanged: (value) {
                      String clean = value.replaceAll('.', '');
                      if (clean.isEmpty) return;

                      int number = int.parse(clean);
                      String formatted = formatRupiah(number);

                      jumlah.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    },
                  ),
                ],
              ),

              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    int jml = int.tryParse(jumlah.text.replaceAll('.', '')) ?? 0;
                    if (jml == 0) return;

                    setState(() {
                      transaksi.add({
                        'nama': tipe == "pengeluaran" ? nama.text : "Saldo",
                        'jumlah': jml,
                        'tipe': tipe
                      });

                      if (tipe == "pengeluaran") {
                        saldo -= jml;
                        pengeluaran += jml;
                      } else {
                        saldo += jml;
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text("Sugeng Rawuh,", style: TextStyle(fontSize: 12, color: Colors.white70)),
                Text("Kocheng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(width: 10),
            const CircleAvatar(
              backgroundColor: accent1,
              child: Icon(Icons.person, color: Colors.white),
            )
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 5),
        child: FloatingActionButton(
          onPressed: showPopup,
          backgroundColor: accent2,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // CARD ATAS
              Row(
                children: [
                  Expanded(child: cardTop("Saldo", saldo, primary)),
                  const SizedBox(width: 10),
                  Expanded(child: cardTop("Pengeluaran", pengeluaran, accent2)),
                ],
              ),

              const SizedBox(height: 20),

              // RIWAYAT SCROLL
              SizedBox(
                height: 110,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) => true,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: transaksi.map((data) {
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: data['tipe'] == "pengeluaran"
                              ? accent2.withOpacity(0.2)
                              : primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: data['tipe'] == "pengeluaran"
                                ? accent2.withOpacity(0.5)
                                : primary.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['nama'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Rp ${formatRupiah(data['jumlah'])}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data['tipe'] == "pengeluaran"
                                    ? accent2
                                    : accent1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PIE CHART STATISTIK
              SizedBox(
                height: 450,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      const Text(
                        "Statistik",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: pengeluaran.toDouble(),
                                color: accent2,
                                title: "Pengeluaran",
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                value: saldo.toDouble(),
                                color: primary,
                                title: "Saldo",
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: accent2, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text("Pengeluaran", style: TextStyle(color: textColor)),
                            ],
                          ),
                          Text("Rp ${formatRupiah(pengeluaran)}", style: const TextStyle(color: accent2, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text("Saldo", style: TextStyle(color: textColor)),
                            ],
                          ),
                          Text("Rp ${formatRupiah(saldo)}", style: const TextStyle(color: primary, fontWeight: FontWeight.bold)),
                        ],
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

  Widget cardTop(String title, int value, Color color) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            "Rp ${formatRupiah(value)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
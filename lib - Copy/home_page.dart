import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int saldo = 1000000;
  int pengeluaran = 0;

  List<Map<String, dynamic>> transaksi = [];

  @override
  void initState() {
    super.initState();
    loadData();
    dummyData();
  }

  void dummyData() {
  if (transaksi.isNotEmpty) return;

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
        'nama': 'Makan',
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
      {
        'nama': 'Laundry',
        'jumlah': 30000,
        'tipe': 'pengeluaran',
        'tanggal': DateTime.now().subtract(const Duration(days: 4)),
      },
      {
        'nama': 'Internet',
        'jumlah': 150000,
        'tipe': 'pengeluaran',
        'tanggal': DateTime.now().subtract(const Duration(days: 6)),
      },
      {
        'nama': 'Makan Malam',
        'jumlah': 40000,
        'tipe': 'pengeluaran',
        'tanggal': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];

    saldo = 0;
    pengeluaran = 0;

    for (var t in transaksi) {
      if (t['tipe'] == "pengeluaran") {
        pengeluaran += t['jumlah'] as int;
        saldo -= t['jumlah'] as int;
      } else {
        saldo += t['jumlah'] as int;
      }
    }
  });

  saveData();
}

  // ================= FORMAT =================
  String formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // ================= STORAGE =================
  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('transaksi', jsonEncode(transaksi));
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

        // hitung ulang saldo & pengeluaran
        saldo = 0;
        pengeluaran = 0;

        for (var t in transaksi) {
          if (t['tipe'] == "pengeluaran") {
            pengeluaran += t['jumlah'] as int;
            saldo -= t['jumlah'] as int;
          } else {
            saldo += t['jumlah'] as int;
          }
        }
      });
    }
  }

  // ================= POPUP =================
  void showPopup() {
    TextEditingController nama = TextEditingController();
    TextEditingController jumlah = TextEditingController();

    FocusNode namaFocus = FocusNode();
    FocusNode jumlahFocus = FocusNode();

    String tipe = "pengeluaran";
    DateTime selectedDate = DateTime.now();

    void simpan() {
      int jml = int.tryParse(jumlah.text.replaceAll('.', '')) ?? 0;
      if (jml == 0) return;

      setState(() {
        transaksi.insert(0, {
          'nama': tipe == "pengeluaran" ? nama.text : "Saldo",
          'jumlah': jml,
          'tipe': tipe,
          'tanggal': selectedDate,
        });

        if (tipe == "pengeluaran") {
          saldo -= jml;
          pengeluaran += jml;
        } else {
          saldo += jml;
        }
      });

      saveData(); // 🔥 simpan
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Transaksi"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // SWITCH
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              tipe = "pengeluaran";
                            });
                          },
                          child: const Text("Pengeluaran"),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              tipe = "saldo";
                            });
                          },
                          child: const Text("Saldo"),
                        ),
                      ),
                    ],
                  ),

                  // INPUT NAMA
                  if (tipe == "pengeluaran")
                    TextField(
                      controller: nama,
                      focusNode: namaFocus,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: "Nama"),
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(jumlahFocus);
                      },
                    ),

                  // INPUT JUMLAH
                  TextField(
                    controller: jumlah,
                    focusNode: jumlahFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(labelText: "Jumlah"),
                    onChanged: (value) {
                      if (value.isEmpty) return;

                      int number = int.parse(value);
                      String formatted = formatRupiah(number);

                      jumlah.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    },
                    onSubmitted: (_) {
                      simpan();
                    },
                  ),

                  const SizedBox(height: 10),

                  // DATE PICKER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setStateDialog(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: const Text("Pilih Tanggal"),
                      )
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: simpan,
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ================= BOX =================
  BoxDecoration boxStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ================= NAVBAR =================
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // PROFILE
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),

            // ACTION
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(transaksi: transaksi),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showPopup,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // SALDO & PENGELUARAN
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: boxStyle(),
                    child: Column(
                      children: [
                        const Text("Saldo"),
                        Text("Rp ${formatRupiah(saldo)}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: boxStyle(),
                    child: Column(
                      children: [
                        const Text("Pengeluaran"),
                        Text("Rp ${formatRupiah(pengeluaran)}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TITLE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: boxStyle(),
              child: const Text("Riwayat Transaksi"),
            ),

            const SizedBox(height: 10),

            // LIST
            Expanded(
              child: Container(
                decoration: boxStyle(),
                child: transaksi.isEmpty
                    ? const Center(child: Text("Belum ada transaksi"))
                    : ListView.builder(
                        itemCount: transaksi.length,
                        itemBuilder: (context, index) {
                          final data = transaksi[index];
                          DateTime tgl = data['tanggal'];

                          return Column(
                            children: [
                              ListTile(
                                title: Text(data['nama']),
                                subtitle: Text(
                                  "${tgl.day}/${tgl.month}/${tgl.year} - Rp ${formatRupiah(data['jumlah'])}",
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
    );
  }
}
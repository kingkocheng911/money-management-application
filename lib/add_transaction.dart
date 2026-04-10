import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {

  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();

  void simpan() {
    String nama = namaController.text;
    int jumlah = int.tryParse(jumlahController.text) ?? 0;

    if (nama.isEmpty || jumlah == 0) return;

    Navigator.pop(context, {
      'nama': nama,
      'jumlah': jumlah,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Transaksi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Transaksi",
              ),
            ),

            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: simpan,
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
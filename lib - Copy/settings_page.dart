import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isDarkMode = false;

  String nama = "User";

  // BOX STYLE
  BoxDecoration boxStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // 🔥 DIALOG GANTI NAMA
  void dialogGantiNama() {
    TextEditingController controller = TextEditingController(text: nama);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ganti Nama"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Nama Baru"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  nama = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  // 🔥 DIALOG GANTI SANDI
  void dialogGantiSandi() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ganti Sandi"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Sandi Baru"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Pengaturan"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 INFO USER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: boxStyle(),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 40),
                  const SizedBox(height: 5),
                  Text(nama),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 GANTI NAMA
            GestureDetector(
              onTap: dialogGantiNama,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: boxStyle(),
                child: const Text("Ganti Nama"),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 GANTI SANDI
            GestureDetector(
              onTap: dialogGantiSandi,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: boxStyle(),
                child: const Text("Ganti Sandi"),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 DARK MODE
            Container(
              padding: const EdgeInsets.all(12),
              decoration: boxStyle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mode Gelap"),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
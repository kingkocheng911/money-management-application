import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String message = "";

  BoxDecoration boxStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // 🔥 SIGN UP
  void signup() async {
    final prefs = await SharedPreferences.getInstance();

    if (username.text.isEmpty || password.text.isEmpty) {
      setState(() {
        message = "Tidak boleh kosong";
      });
      return;
    }

    await prefs.setString('username', username.text);
    await prefs.setString('password', password.text);

    setState(() {
      message = "Akun berhasil dibuat";
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              decoration: boxStyle(),
              child: TextField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: boxStyle(),
              child: TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(message, style: const TextStyle(color: Colors.green)),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              decoration: boxStyle(),
              child: TextButton(
                onPressed: signup,
                child: const Text("Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
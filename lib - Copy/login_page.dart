import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'signup_page.dart'; // 🔥 WAJIB

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String message = "";

  BoxDecoration boxStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    );
  }

  // 🔥 LOGIN
  void login() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', 'admin');
    await prefs.setString('password', '1234');

    String? savedUser = prefs.getString('username');
    String? savedPass = prefs.getString('password');

    // VALIDASI KOSONG
    if (username.text.isEmpty || password.text.isEmpty) {
      setState(() {
        message = "Tidak boleh kosong";
      });
      return;
    }

    if (username.text == savedUser && password.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        message = "Username / Password salah";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView( // 🔥 BIAR TIDAK OVERFLOW
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // USERNAME
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

              // PASSWORD
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

              // MESSAGE
              Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),

              const SizedBox(height: 10),

              // LOGIN BUTTON
              Container(
                width: double.infinity,
                decoration: boxStyle(),
                child: TextButton(
                  onPressed: login,
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 10),

              // KE SIGNUP
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: const Text("Belum punya akun? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
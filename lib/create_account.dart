import 'package:bakul_payu/forget_password.dart';
import 'package:bakul_payu/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordconfirmationController =
      TextEditingController();
  final TextEditingController _mobilephoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _registerAccount() async {
    try {
      String email = _emailController.text;
      String name = _nameController.text;
      String password = _passwordController.text;
      String mobilePhone = _mobilephoneController.text;

      // Validate password confirmation
      if (_passwordController.text != _passwordconfirmationController.text) {
        // Passwords do not match
        // Handle this according to your app's UX
        print('Passwords do not match');
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Store additional user information in Cloud Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'mobilePhone': mobilePhone,
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pembuatan Akun Berhasil!'),
            content: const Text('Akun telah berhasil didaftarkan.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          );
        },
      );
      // Successfully logged in, navigate to the home page
    } catch (e) {
      // Handle login error, e.g., show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Proses pembuatan akun gagal, silahkan periksa kembali email dan kata sandi!!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _haveAccount() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _forgotPassword() {
    // ... (your existing _forgotPassword method code)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakul Payu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Masukkan Kata sandi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordconfirmationController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Kata Sandi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mobilephoneController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Masukkan Nomor HP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerAccount,
              child: const Text('Daftar'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _haveAccount,
                  child: const Text('Punya Akun?'),
                ),
                TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('Lupa Kata Sandi?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

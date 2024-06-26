// ignore_for_file: use_build_context_synchronously

import 'package:bakul_payu/admin_homepage.dart';
import 'package:bakul_payu/forget_password.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/create_account.dart';
import 'package:bakul_payu/suspended.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _loginPressed() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      String uid = userCredential.user!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        String userType = userSnapshot.get('userType');
        String suspensionStatus = userSnapshot.get('storeSuspension');
        if (userType == 'user') {
          if (suspensionStatus == 'suspended') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SuspendedPage(),
            ));
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
          return;
        } else if (userType == 'admin') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminHomePage(),
            ),
          );
          return;
        }
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Login gagal. Mohon coba lagi.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Login gagal. Mohon coba lagi.'),
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

  void _forgotPassword() {
    print('Forgot Password clicked');
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ForgetPasswordPage()));
  }

  void _createAccountPressed() {
    print('Create Account clicked');
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bakul Payu'),
          automaticallyImplyLeading: false,
        ),
        body: WillPopScope(
          onWillPop: () async {
            // Show a confirmation dialog
            bool shouldClose = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Exit'),
                  content: const Text('Do you want to close the application?'),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
            return shouldClose;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Kata Sandi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loginPressed,
                    child: const Text('Masuk'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Lupa Kata Sandi?'),
                      ),
                      TextButton(
                        onPressed: _createAccountPressed,
                        child: const Text('Buat Akun'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

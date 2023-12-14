import 'package:bakul_payu/forget_password.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/create_account.dart'; // Assuming your RegisterPage file is named register.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
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

      // Successfully logged in, navigate to the home page
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
      
    } catch (e) {
      // Handle login error, e.g., show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to sign in. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgetPasswordPage()));
  }

  void _createAccountPressed() {
    print('Create Account clicked');
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bakul Payu'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginPressed,
              child: Text('Masuk'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _forgotPassword,
                  child: Text('Lupa Kata Sandi??'),
                ),
                TextButton(
                  onPressed: _createAccountPressed,
                  child: Text('Buat Akun'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
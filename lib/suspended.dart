import 'package:bakul_payu/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuspendedPage extends StatefulWidget {
  const SuspendedPage({super.key});

  @override
  State<SuspendedPage> createState() => _SuspendedPageState();
}

class _SuspendedPageState extends State<SuspendedPage> {
  @override
  void initState() {
    super.initState();
    logoutUser();
  }

  Future<void> logoutUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bakul Payu Admin"),
          automaticallyImplyLeading: false,
        ),
        body: WillPopScope(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning,
                    size: 200,
                  ),
                  const Text(
                      "Akun anda telah di-suspend mohon segera menhubungi admin kami melalui email: bakulpayuadmin@gmail.com"),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text("Ok"))
                ],
              ),
            ),
          ),
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
        ));
  }
}

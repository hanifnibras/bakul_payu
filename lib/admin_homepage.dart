// ignore_for_file: use_build_context_synchronously

import 'package:bakul_payu/admin_report.dart';
import 'package:bakul_payu/admin_user_list.dart';
import 'package:bakul_payu/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu Admin"),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final FirebaseAuth auth = FirebaseAuth.instance;
                await auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
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
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                0,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Admin Page',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AdminUserList()),
                          );
                        },
                        child: const Text("View user list")),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AdminReport()),
                          );
                        },
                        child: const Text("View user reports")),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

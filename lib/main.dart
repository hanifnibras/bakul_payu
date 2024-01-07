import 'package:bakul_payu/admin_homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_account.dart';
import 'login.dart';
import 'forget_password.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({Key? key, this.user}) : super(key: key);

  Future<String> getUserType() async {
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userSnapshot.exists) {
        String userType = userSnapshot.get('userType');
        return userType;
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: getUserType(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            String userType = snapshot.data ?? "";
            if (userType == 'user') {
              return const HomePage();
            }
            if (userType == 'admin') {
              return const AdminHomePage();
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}

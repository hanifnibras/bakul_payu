import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobilephoneController = TextEditingController();

  String _existingemail = "Default Name";
  String _existingmobilephone = "Default Number";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    var db = FirebaseFirestore.instance;
    final docRef = db.collection("users").doc(user?.uid);

    try {
      final documentSnapshot = await docRef.get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        _existingemail = data!['email'];
        _existingmobilephone = data['mobilePhone'];
        _emailController = TextEditingController(text: _existingemail);
        _mobilephoneController =
            TextEditingController(text: _existingmobilephone);
      }
    } catch (e) {
      print('Error getting document: $e');
    }
  }

  void _editPressed(BuildContext context) async {
    String email = _emailController.text.trim();
    String mobilephone = _mobilephoneController.text.trim();

    try {
      await _firestore
          .collection("users")
          .doc(user?.uid)
          .update({'email': email, 'mobilePhone': mobilephone});
    } catch (e) {
      if (e is FirebaseException) {
        print('Firebase error: ${e.message}');
      } else {
        print('Error: $e');
      }
    }
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "email",
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: _existingemail),
                  )
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mobile Phone",
                  ),
                  TextField(
                    controller: _mobilephoneController,
                    decoration: InputDecoration(hintText: _existingmobilephone),
                  )
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  _editPressed(context);
                },
                child: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

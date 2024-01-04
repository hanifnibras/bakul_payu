import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;
final uid = FirebaseAuth.instance.currentUser?.uid;

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  late String _existingName;
  late String _existingEmail;
  late String _existingPhone;

  @override
  void initState() {
    super.initState();
    // Fetch existing user data from Firestore
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (uid != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          _existingName = userData['name'] ?? 'Default Name';
          _existingEmail = userData['email'] ?? 'Default Email';
          _existingPhone = userData['mobilePhone'] ?? 'Default Phone';
          nameController = TextEditingController(text: _existingName);
          emailController = TextEditingController(text: _existingEmail);
          phoneController = TextEditingController(text: _existingPhone);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ganti Nama:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Ketik Nama Baru.',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ganti Alamat Email:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Ketik Alamat Email Baru',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ganti Nomor HP:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                hintText: 'Ketik Nomor HP Baru',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                String newEmail = emailController.text.trim();
                String newPhone = phoneController.text.trim();
                try {
                  await _firestore.collection("users").doc(uid).update({
                    'name': newName,
                    'email': newEmail,
                    'mobilePhone': newPhone
                  });
                } catch (e) {
                  if (e is FirebaseException) {
                    print('Firebase error: ${e.message}');
                  } else {
                    print('Error: $e');
                  }
                }
              },
              child: const Text('Simpan Pembaharuan'),
            ),
          ],
        ),
      ),
    );
  }
}

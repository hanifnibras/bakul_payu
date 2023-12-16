import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          _existingName = userData['name'] ?? 'Default Name';
          _existingEmail = userData['email'] ?? 'Default Email';
          _existingPhone = userData['phone'] ?? 'Default Phone';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganti Nama:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Ketik Nama Baru.',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ganti Alamat Email:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Ketik Alamat Email Baru',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ganti Nomor HP:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Ketik Nomor HP Baru',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement the logic to update user profile
                String newName = nameController.text;
                String newEmail = emailController.text;
                String newPhone = phoneController.text;

                // You can add your logic here to update the user's profile

                // Print the updated details for now
                print('Updated Profile: Name - $newName, Email - $newEmail, Phone - $newPhone');
              },
              child: Text('Simpan Pembaharuan'),
            ),
          ],
        ),
      ),
    );
  }
}

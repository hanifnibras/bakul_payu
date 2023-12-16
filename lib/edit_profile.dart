import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
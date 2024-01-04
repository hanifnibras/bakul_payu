import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

final uid = FirebaseAuth.instance.currentUser?.uid;

class _SellerPageState extends State<SellerPage> {
  TextEditingController rekeningController = TextEditingController();
  late String _existingRekening;

  @override
  void initState() {
    super.initState();
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
    if (uid != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          _existingRekening = userData['rekening'] ?? '';
          rekeningController = TextEditingController(text: _existingRekening);
        });
      }
    }
  }

  Future<String> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      String filePath = 'images/seller/$imageName';

      Reference storageReference = FirebaseStorage.instance.ref(filePath);

      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);

      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> updateQrisURL(String imageURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'qrisLink': imageURL});
      print('Firestore updated with image URL');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> updateShopeeURL(String imageURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'shopeeLink': imageURL});
      print('Firestore updated with image URL');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      String fileExtension = pickedImage.path.split('.').last;
      String imageName =
          "${DateTime.now().millisecondsSinceEpoch}.$fileExtension";

      String downloadURL = await uploadImageToStorage(
        File(pickedImage.path),
        imageName,
      );

      if (downloadURL.isNotEmpty) {
        type == "qris"
            ? await updateQrisURL(downloadURL)
            : await updateShopeeURL(downloadURL);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakul Payu'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const Text(
            "Pengaturan Toko",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              String type = "qris";
              _pickImage(ImageSource.gallery, type);
            },
            child: const Text('Unggah Foto QRIS'),
          ),
          ElevatedButton(
            onPressed: () {
              String type = "shopee";
              _pickImage(ImageSource.gallery, type);
            },
            child: const Text('Unggah Foto ShopeePay'),
          ),
          const Text(
            'Edit Informasi Bank:',
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: rekeningController,
            decoration: const InputDecoration(
              hintText: 'Ketik nomor rekening bank',
            ),
          ),
        ]),
      ),
    );
  }
}

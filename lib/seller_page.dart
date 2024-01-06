import 'package:bakul_payu/edit_profile.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/seller_crud_page.dart';
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

  Future<void> pickImage(ImageSource source, String type) async {
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
    int currentPageIndex = 2;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SellerPage()),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SellerPage()),
              );
              break;
            case 3:
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const EditProfilePage()),
              );
              break;
          }
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt_long),
            icon: Icon(Icons.receipt_long_outlined),
            label: 'My Orders',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.business),
            icon: Icon(Icons.business_outlined),
            label: 'Seller Page',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Bakul Payu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Seller Page',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Daftar Produk",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SellerCrudPage()),
                );
              },
              child: const Text('Lihat Daftar Produk'),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Order",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Lihat Daftar Pesanan'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pengaturan Toko",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String type = "qris";
                pickImage(ImageSource.gallery, type);
              },
              child: const Text('Unggah Barcode QRIS'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String type = "shopee";
                pickImage(ImageSource.gallery, type);
              },
              child: const Text('Unggah Barcode ShopeePay'),
            ),
            const SizedBox(height: 10),
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
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:bakul_payu/edit_profile.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/seller_crud_page.dart';
import 'package:bakul_payu/seller_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bakul_payu/my_order.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController rekeningController = TextEditingController();
  String _existingRekening = "";
  String qrisLink = "";
  String shopeeLink = "";
  bool myOrderNotification = false;
  bool sellerPageNotification = false;

  @override
  void initState() {
    super.initState();
    _fetchSellerData();
    myOrderDotNotification();
    sellerPageDotNotification();
  }

  Future<void> myOrderDotNotification() async {
    if (uid != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('buyerId', isEqualTo: uid)
              .where('transactionStatus',
                  whereIn: ["confirmed", "finished", "declined"]).get();
      setState(() {
        myOrderNotification = snapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> sellerPageDotNotification() async {
    if (uid != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore
              .instance
              .collection('transactions')
              .where('sellerId', isEqualTo: uid)
              .where('transactionStatus',
                  whereIn: ["pending", "reviewed"]).get();
      setState(() {
        sellerPageNotification = snapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> _fetchSellerData() async {
    if (uid != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          _existingRekening = userData['rekening'] ?? '';
          qrisLink = userData['qrisLink'] ?? '';
          shopeeLink = userData['shopeeLink'] ?? '';
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
                MaterialPageRoute(builder: (context) => const MyOrder()),
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
        destinations: <Widget>[
          const NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          if (myOrderNotification == true) ...[
            const NavigationDestination(
              selectedIcon: Icon(Icons.receipt_long),
              icon: Badge(
                label: Text('!'),
                child: Icon(Icons.receipt_long_outlined),
              ),
              label: 'My Orders',
            ),
          ] else ...[
            const NavigationDestination(
              selectedIcon: Icon(Icons.receipt_long),
              icon: Icon(Icons.receipt_long_outlined),
              label: 'My Orders',
            ),
          ],
          if (sellerPageNotification == true) ...[
            const NavigationDestination(
              selectedIcon: Icon(Icons.business),
              icon: Badge(
                label: Text('!'),
                child: Icon(Icons.business_outlined),
              ),
              label: 'Seller Page',
            ),
          ] else ...[
            const NavigationDestination(
              selectedIcon: Icon(Icons.business),
              icon: Icon(Icons.business_outlined),
              label: 'Seller Page',
            )
          ],
          const NavigationDestination(
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
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      sellerSnapshot) {
                if (!sellerSnapshot.hasData || !sellerSnapshot.data!.exists) {
                  return const Center(
                    child: Text('Rating information not available'),
                  );
                }
                final Map<String, dynamic> sellerData =
                    sellerSnapshot.data!.data()!;
                int rating = sellerData['rating'] ?? 0;
                int reviewCount = sellerData['reviewCount'] ?? 0;
                double storeRating = reviewCount > 0 ? rating / reviewCount : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rating Toko Anda",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: index < storeRating
                                  ? Colors.yellow
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text('(${storeRating.toStringAsFixed(2)})'),
                        const SizedBox(
                          width: 10,
                        ),
                        Text('($reviewCount reviews)'),
                      ],
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SellerOrder()),
                );
              },
              child: const Text('Lihat Daftar Pesanan'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pengaturan Toko",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (qrisLink.isNotEmpty) ...[
              Image.network(
                qrisLink,
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
            ElevatedButton(
              onPressed: () {
                String type = "qris";
                pickImage(ImageSource.gallery, type);
              },
              child: const Text('Unggah Barcode QRIS'),
            ),
            const SizedBox(height: 10),
            if (shopeeLink.isNotEmpty) ...[
              Image.network(
                height: 300,
                shopeeLink,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
            ElevatedButton(
              onPressed: () {
                String type = "shopee";
                pickImage(ImageSource.gallery, type);
              },
              child: const Text('Unggah Barcode ShopeePay'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Edit Informasi Rekening:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: rekeningController,
              decoration: const InputDecoration(
                hintText: 'Ketik nomor rekening bank',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore.collection("users").doc(uid).update({
                    'rekening': rekeningController.text.trim(),
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content:
                            const Text('Nomor rekening berhasil di update'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  if (e is FirebaseException) {
                    print('Firebase error: ${e.message}');
                  } else {
                    print('Error: $e');
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Nomor rekening gagal di update'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Update Informasi Rekening'),
            ),
          ]),
        ),
      ),
    );
  }
}

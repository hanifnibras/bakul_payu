// ignore_for_file: use_build_context_synchronously

import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/my_order.dart';
import 'package:bakul_payu/seller_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool myOrderNotification = false;
  bool sellerPageNotification = false;
  int currentPageIndex = 3;

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

  @override
  void initState() {
    super.initState();
    myOrderDotNotification();
    sellerPageDotNotification();
  }

  @override
  Widget build(BuildContext context) {
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
                // Do nothing, already on the EditProfilePage
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
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final userData = snapshot.data?.data();
                  if (userData != null) {
                    nameController.text = userData['name'] ?? 'Default Name';
                    emailController.text = userData['email'] ?? 'Default Email';
                    phoneController.text =
                        userData['mobilePhone'] ?? 'Default Phone';
                    addressController.text =
                        userData['address'] ?? 'Default Address';
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                      const Text(
                        'Ganti Alamat:',
                        style: TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          hintText: 'Ketik Alamat Baru',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _editPressed();
                        },
                        child: const Text('Simpan Pembaharuan'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ));
  }

  Future<void> _editPressed() async {
    String newName = nameController.text.trim();
    String newEmail = emailController.text.trim();
    String newPhone = phoneController.text.trim();
    String newAddress = addressController.text.trim();
    if (newAddress.isNotEmpty &&
        newPhone.isNotEmpty &&
        newEmail.isNotEmpty &&
        newEmail.isNotEmpty) {
      try {
        await _firestore.collection("users").doc(uid).update({
          'name': newName,
          'email': newEmail,
          'mobilePhone': newPhone,
          'address': newAddress,
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Update Berhasil'),
              content: const Text('Profile anda telah berhasil di update'),
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
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Mohon pastikan semua kolom telah diisi.'),
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
      return;
    }
  }
}

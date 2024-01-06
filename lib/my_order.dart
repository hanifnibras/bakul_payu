import 'package:bakul_payu/edit_profile.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/seller_page.dart';
import 'package:bakul_payu/store_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  int selectedStars = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> fetchSellerName(String sellerId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();
      if (userSnapshot.exists) {
        String sellerName = userSnapshot.data()?['name'] ?? '';
        return sellerName;
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    Map<String, String> paymentStatusTextMap = {
      'declined': 'Order is declined',
      'pending': 'Waiting payment confirmation',
      'confirmed': 'Order is processed',
      'finished': 'Order is finished',
      'reviewed': 'Thank you for your review'
    };
    int currentPageIndex = 1;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('buyerId', isEqualTo: uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No order is found',
                          ),
                        ],
                      ));
                    }
                    if (snapshot.hasData) {
                      final List<QueryDocumentSnapshot> orders =
                          snapshot.data!.docs;
                      return Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final orderDetails = orders[index].data()
                                    as Map<String, dynamic>;
                                String buyerId = orderDetails['buyerId'];
                                String paymentImgUrl =
                                    orderDetails['paymentImgUrl'];
                                int totalPrice = orderDetails['totalPrice'];
                                String sellerId = orderDetails['sellerId'];
                                String transactionId = orders[index].id;
                                String productPriceString =
                                    totalPrice.toString();
                                String transactionStatus =
                                    orderDetails['transactionStatus'];
                                final List<dynamic> cartItems =
                                    orderDetails['cartItems'] as List<dynamic>;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 200,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: cartItems.length,
                                          itemBuilder: (context, index) {
                                            final product = cartItems[index];
                                            String productImgUrl =
                                                product['productImgUrl'];
                                            int productPrice =
                                                product['productPrice'];
                                            String productTitle =
                                                product['productTitle'];
                                            int quantity = product['quantity'];
                                            double cardWidth =
                                                screenSize.width / 3;
                                            return Card(
                                              child: Container(
                                                width: cardWidth,
                                                padding: EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // Display your product information here
                                                    Image.network(productImgUrl,
                                                        height: 100,
                                                        width: cardWidth),
                                                    const SizedBox(height: 10),
                                                    Text(productTitle),
                                                    Text(
                                                        'Quantity: ${quantity.toString()}'),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text("Seller: "),
                                        FutureBuilder<String>(
                                          future: fetchSellerName(sellerId),
                                          builder:
                                              (context, sellerNameSnapshot) {
                                            if (sellerNameSnapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              String sellerName =
                                                  sellerNameSnapshot.data ??
                                                      'Unknown Seller';
                                              return ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StorePage(
                                                        sellerId: sellerId,
                                                        sellerName: sellerName,
                                                        cartItems: const [],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: Text(
                                                    '$sellerName\'s Store'),
                                              );
                                            } else {
                                              return const Text("-");
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        "Total Price: Rp${totalPrice.toString()}"),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text("Status: "),
                                        Text(paymentStatusTextMap[
                                                transactionStatus] ??
                                            'Unknown Status'),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (transactionStatus == 'finished') ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Berikan Rating'),
                                                    content: Row(
                                                      children: [
                                                        const Text(
                                                            "Rate this product: "),
                                                        ...List.generate(
                                                          5,
                                                          (index) =>
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                selectedStars =
                                                                    index + 1;
                                                              });
                                                            },
                                                            child: Icon(
                                                              Icons.star,
                                                              color: index <
                                                                      selectedStars
                                                                  ? Colors
                                                                      .yellow
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Batalkan'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text('Ya'),
                                                        onPressed: () async {
                                                          try {
                                                            await _firestore
                                                                .collection(
                                                                    "users")
                                                                .doc(sellerId)
                                                                .update({
                                                              'rating': FieldValue
                                                                  .increment(
                                                                      selectedStars),
                                                              'reviewCount':
                                                                  FieldValue
                                                                      .increment(
                                                                          1),
                                                            });
                                                            await _firestore
                                                                .collection(
                                                                    "transactions")
                                                                .doc(
                                                                    transactionId)
                                                                .update({
                                                              'transactionStatus':
                                                                  'reviewed',
                                                            });
                                                          } catch (e) {
                                                            if (e
                                                                is FirebaseException) {
                                                              print(
                                                                  'Firebase error: ${e.message}');
                                                            } else {
                                                              print(
                                                                  'Error: $e');
                                                            }
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: const Text("Post Review"),
                                      ),
                                    ],
                                    const Divider(
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      thickness: 1,
                                    ),
                                  ],
                                );
                              })
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  })
            ],
          ),
        ),
      ),
    );
  }
}

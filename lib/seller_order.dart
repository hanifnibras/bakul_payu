import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerOrder extends StatefulWidget {
  const SellerOrder({super.key});

  @override
  State<SellerOrder> createState() => _SellerOrderState();
}

class _SellerOrderState extends State<SellerOrder> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<String> fetchSellerName(String buyerId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(buyerId)
              .get();
      if (userSnapshot.exists) {
        String buyerName = userSnapshot.data()?['name'] ?? '';
        return buyerName;
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  Future<String> fetchSellerAddress(String buyerId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(buyerId)
              .get();
      if (userSnapshot.exists) {
        String buyerAddress = userSnapshot.data()?['address'] ?? '';
        return buyerAddress;
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
                'Orders',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('sellerId', isEqualTo: uid)
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
                                String productPriceString =
                                    totalPrice.toString();
                                String transactionId = orders[index].id;
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                        const Text("Buyer Name: "),
                                        FutureBuilder<String>(
                                          future: fetchSellerName(buyerId),
                                          builder:
                                              (context, buyerNameSnapshot) {
                                            if (buyerNameSnapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              String buyerName =
                                                  buyerNameSnapshot.data ??
                                                      'Unknown Seller';
                                              return Text(buyerName);
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
                                    Row(
                                      children: [
                                        const Text("Buyer Address: "),
                                        FutureBuilder<String>(
                                          future: fetchSellerAddress(buyerId),
                                          builder:
                                              (context, buyerAddressSnapshot) {
                                            if (buyerAddressSnapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              String buyerAddress =
                                                  buyerAddressSnapshot.data ??
                                                      'Unknown Seller';
                                              return Text(buyerAddress);
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
                                    if (transactionStatus == 'pending') ...[
                                      const Text("Payment Proof:"),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Image.network(paymentImgUrl,
                                          fit: BoxFit.contain, height: 150),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Menolak'),
                                                      content: const Text(
                                                          'Apakah anda yakin untuk menolak pembayaran?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                              'Tidak'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              const Text('Ya'),
                                                          onPressed: () async {
                                                            try {
                                                              await _firestore
                                                                  .collection(
                                                                      "transactions")
                                                                  .doc(
                                                                      transactionId)
                                                                  .update({
                                                                'transactionStatus':
                                                                    'declined',
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Text("Tolak")),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Konfirmasi'),
                                                      content: const Text(
                                                          'Apakah anda yakin untuk menkonfirmasi pembayaran?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                              'Tidak'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              const Text('Ya'),
                                                          onPressed: () async {
                                                            try {
                                                              await _firestore
                                                                  .collection(
                                                                      "transactions")
                                                                  .doc(
                                                                      transactionId)
                                                                  .update({
                                                                'transactionStatus':
                                                                    'confirmed',
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Text("Konfirmasi"))
                                        ],
                                      )
                                    ] else if (transactionStatus ==
                                        'confirmed') ...[
                                      const Text("Payment has been confirmed"),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            child:
                                                const Text("Selesaikan Order"),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Konfirmasi'),
                                                    content: const Text(
                                                        'Apakah anda yakin untuk menyelesaikan order?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child:
                                                            const Text('Tidak'),
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
                                                                    "transactions")
                                                                .doc(
                                                                    transactionId)
                                                                .update({
                                                              'transactionStatus':
                                                                  'finished',
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
                                          )
                                        ],
                                      )
                                    ] else if (transactionStatus ==
                                        'finished') ...[
                                      const Text("Order is finished"),
                                    ] else if (transactionStatus ==
                                        'reviewed') ...[
                                      const Text("Produk telah di review"),
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

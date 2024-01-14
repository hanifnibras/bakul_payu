import 'package:bakul_payu/cart_item.dart';
import 'package:bakul_payu/chat_room.dart';
import 'package:bakul_payu/create_report.dart';
import 'package:bakul_payu/product_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final List<CartItem> cartItems;
  const StorePage(
      {super.key,
      required this.sellerId,
      required this.sellerName,
      required this.cartItems});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    print("Initial Cart Items: ${widget.cartItems}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu"),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              "${widget.sellerName}'s Store",
              style: const TextStyle(fontSize: 20),
            )),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.sellerId)
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
                return Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color:
                              index < storeRating ? Colors.yellow : Colors.grey,
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
                ));
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(
                      receiverId: widget.sellerId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.message),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('Chat With ${widget.sellerName}\'s Store')
                ],
              ),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('seller_id', isEqualTo: widget.sellerId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No product is found',
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> products =
                        snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productDetails =
                            products[index].data() as Map<String, dynamic>;
                        String productCat = productDetails['product_cat'];
                        String productDesc = productDetails['product_desc'];
                        String productImgUrl =
                            productDetails['product_img_url'];
                        int productPrice = productDetails['product_price'];
                        String productTitle = productDetails['product_title'];
                        String sellerId = productDetails['seller_id'];
                        String productPriceString = productPrice.toString();
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                          productCat: productCat,
                                          productDesc: productDesc,
                                          productImgUrl: productImgUrl,
                                          productPrice: productPrice,
                                          productTitle: productTitle,
                                          cartItems: widget.cartItems,
                                          sellerId: sellerId,
                                        )),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        productImgUrl,
                                        fit: BoxFit.cover,
                                        height: 90,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16.0, 0, 0, 0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  productTitle,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("Rp$productPriceString")
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                }),
            ElevatedButton(
                onPressed: () {
                  if (uid != null) {
                    if (uid != widget.sellerId) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CreateReport(
                                customerId: uid,
                                sellerId: widget.sellerId,
                                sellerName: widget.sellerName)),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Seller cannot report their own store'),
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
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content:
                              const Text('System error mohon login kembali'),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_rounded),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Report Store'),
                  ],
                )),
          ],
        ),
      )),
    );
  }
}

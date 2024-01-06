import 'package:bakul_payu/add_product.dart';
import 'package:bakul_payu/edit_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerCrudPage extends StatefulWidget {
  const SellerCrudPage({super.key});

  @override
  State<SellerCrudPage> createState() => _SellerCrudPageState();
}

class _SellerCrudPageState extends State<SellerCrudPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  String sellerName = "";
  String qrisLink = "";
  String shopeeLink = "";
  String rekening = "";

  @override
  void initState() {
    super.initState();
    fetchSellerData();
  }

  Future<void> fetchSellerData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          sellerName = userSnapshot.data()?['name'] ?? '';
          qrisLink = userSnapshot.data()?['qrisLink'] ?? '';
          shopeeLink = userSnapshot.data()?['shopeeLink'] ?? '';
          rekening = userSnapshot.data()?['rekening'] ?? '';
        });
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakul Payu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "$sellerName's Store",
                style: const TextStyle(fontSize: 20),
              )),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (qrisLink.isNotEmpty ||
                      shopeeLink.isNotEmpty ||
                      rekening.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AddProduct()),
                    );
                  } else {
                    AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                          'Tolong berikan metode pembayaran untuk customer (QRIS, Shopee, atau rekening)'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
                },
                child: const Text('Tambah Produk Baru'),
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('seller_id', isEqualTo: uid)
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
                          String prodId = products[index].id;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {},
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(16.0),
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16.0, 0, 0, 0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          productTitle,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "Rp$productPriceString")
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.create_outlined),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProduct(
                                                            prodId: prodId,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Remove Item"),
                                                      content: const Text(
                                                          "Are you sure you want to delete this item from your store?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            try {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'products')
                                                                  .doc(prodId)
                                                                  .delete();
                                                              setState(() {});
                                                            } catch (error) {
                                                              print(
                                                                  'Error deleting product: $error');
                                                            }
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              "Remove"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },
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

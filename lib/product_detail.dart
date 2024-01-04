import 'package:bakul_payu/store_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'checkout.dart';
import 'package:bakul_payu/cart_item.dart';

class ProductDetailPage extends StatefulWidget {
  final String productCat;
  final String productDesc;
  final String productImgUrl;
  final int productPrice;
  final String productTitle;
  final String sellerId;
  List<CartItem> cartItems;
  ProductDetailPage({
    Key? key,
    required this.productCat,
    required this.productDesc,
    required this.productImgUrl,
    required this.productPrice,
    required this.productTitle,
    required this.sellerId,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String sellerName = "";

  @override
  void initState() {
    super.initState();
    fetchSellerName();
    print("Initial Cart Items: ${widget.cartItems}");
  }

  Future<void> fetchSellerName() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.sellerId)
              .get();

      if (userSnapshot.exists) {
        setState(() {
          sellerName = userSnapshot.data()?['name'] ?? '';
        });
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
  }

  void addToCart() {
    // Convert the cartItems to a modifiable list
    List<CartItem> modifiableCartItems = List.from(widget.cartItems);

    bool itemExists = modifiableCartItems.any(
      (item) => item.productTitle == widget.productTitle,
    );

    setState(() {
      if (!itemExists) {
        modifiableCartItems.add(
          CartItem(
            productImgUrl: widget.productImgUrl,
            productTitle: widget.productTitle,
            productPrice: widget.productPrice,
          ),
        );
        // Update the widget's cartItems with the modifiable list
        widget.cartItems = List.from(modifiableCartItems);
        print("Updated Cart Items: ${widget.cartItems}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Image.network(
                widget.productImgUrl,
                fit: BoxFit.contain,
                width: screenSize.width,
                height: screenSize.height - screenSize.height * 50 / 100,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    widget.productTitle,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "Rp${widget.productPrice}",
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [Text(widget.productDesc)],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Color.fromRGBO(0, 0, 0, 1),
                thickness: 1.0,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text("Seller: "),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StorePage(
                            sellerId: widget.sellerId,
                            sellerName: sellerName,
                            cartItems: widget.cartItems,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('$sellerName\'s Store'),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    addToCart();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          sellerId: widget.sellerId,
                          sellerName: sellerName,
                          cartItems: widget.cartItems,
                        ),
                      ),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

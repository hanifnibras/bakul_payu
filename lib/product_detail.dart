import 'package:flutter/material.dart';
import 'checkout.dart';

class ProductDetailPage extends StatefulWidget {
  final String productCat;
  final String productDesc;
  final String productImgUrl;
  final int productPrice;
  final String productTitle;
  const ProductDetailPage(
      {super.key,
      required this.productCat,
      required this.productDesc,
      required this.productImgUrl,
      required this.productPrice,
      required this.productTitle});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu"),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  "Rp" + widget.productPrice.toString(),
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [Text(widget.productDesc)],
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                            productCat: widget.productCat,
                            productImgUrl: widget.productImgUrl,
                            productPrice: widget.productPrice,
                            productTitle: widget.productTitle,
                          )),
                ),
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

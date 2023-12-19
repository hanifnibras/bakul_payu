import 'package:flutter/material.dart';
import 'process_payment.dart';

class CheckoutPage extends StatefulWidget {
  final String productCat;
  final String productImgUrl;
  final int productPrice;
  final String productTitle;
  const CheckoutPage(
      {super.key,
      required this.productCat,
      required this.productImgUrl,
      required this.productPrice,
      required this.productTitle});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu"),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            const Text(
              "Checkout",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
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
                        widget.productImgUrl,
                        fit: BoxFit.cover,
                        height: 90,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.productTitle,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text("Quantity: $quantity"),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (quantity > 1) {
                                        quantity--;
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Total Price: ${widget.productPrice * quantity}"),
            const SizedBox(
              height: 20,
            ),
            const ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Image(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/qris-logo.png'),
                  height: 30,
                ),
              ),
              children: <Widget>[Image(image: AssetImage('assets/qris.png'))],
            ),
            const SizedBox(
              height: 10,
            ),
            const ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Image(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/shopeepay-logo.png'),
                  height: 30,
                ),
              ),
              children: <Widget>[
                Image(image: AssetImage('assets/shopee-qr.jpg'))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Image(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/bca-logo.png'),
                  height: 30,
                ),
              ),
              children: <Widget>[
                Text("A/N: Bakul Payu, No. Rek: 1209417248819")
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ProcessPaymentPage()),
                ),
                child: const Text('Submit Payment'),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

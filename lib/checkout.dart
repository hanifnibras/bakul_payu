import 'package:bakul_payu/store_page.dart';
import 'package:flutter/material.dart';
import 'process_payment.dart';
import 'package:bakul_payu/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  final String sellerName;
  final String sellerId;
  final List<CartItem> cartItems;

  const CheckoutPage({
    Key? key,
    required this.sellerName,
    required this.cartItems,
    required this.sellerId,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    print("Initial Cart Items: ${widget.cartItems}");
  }

  int calculateTotalPrice() {
    int total = 0;
    for (var cartItem in widget.cartItems) {
      total += cartItem.productPrice * cartItem.quantity;
    }
    return total;
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
            children: [
              Text(
                "Checkout from ${widget.sellerName}'s Store",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < widget.cartItems.length; i++) ...[
                _buildCartItem(widget.cartItems[i]),
                const SizedBox(
                  height: 15,
                )
              ],
              Text(
                "Total Price: Rp${calculateTotalPrice()}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              const ExpansionTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/bank-logo.png'),
                    height: 30,
                  ),
                ),
                children: <Widget>[
                  Text("A/N: Bakul Payu, No. Rek: 1209417248819"),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StorePage(
                          sellerId: widget.sellerId,
                          sellerName: widget.sellerName,
                          cartItems: widget.cartItems,
                        ),
                      ),
                    );
                  },
                  child:
                      Text('Buy more item from ${widget.sellerName}\'s store'),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProcessPaymentPage(),
                    ),
                  ),
                  child: const Text('Submit Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Card(
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
                cartItem.productImgUrl,
                fit: BoxFit.cover,
                height: 150,
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
                        cartItem.productTitle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Quantity: ${cartItem.quantity}"),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (cartItem.quantity > 1) {
                              cartItem.quantity--;
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            cartItem.quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                          "Item Price: ${cartItem.productPrice * cartItem.quantity}"),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remove Item"),
                                content: const Text(
                                    "Are you sure you want to remove this item from the cart?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.cartItems.remove(cartItem);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Remove"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

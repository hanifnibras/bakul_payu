import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Item {
  String name;
  double price;

  Item({required this.name, required this.price});
}

class Order {
  List<Item> items;
  DateTime dateTime;

  Order({required this.items, required this.dateTime});
}

class MyApp extends StatelessWidget {
  final List<Item> shopItems = [
    Item(name: 'Item 1', price: 10.0),
    Item(name: 'Item 2', price: 20.0),
    Item(name: 'Item 3', price: 15.0),
  ];

  List<Order> orderHistory = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SellerSidePage(
        shopItems: shopItems,
        orderHistory: orderHistory,
      ),
    );
  }
}

class SellerSidePage extends StatefulWidget {
  final List<Item> shopItems;
  final List<Order> orderHistory;

  SellerSidePage({required this.shopItems, required this.orderHistory});

  @override
  _SellerSidePageState createState() => _SellerSidePageState();
}

class _SellerSidePageState extends State<SellerSidePage> {
  List<Item> cart = [];

  void addToCart(Item item) {
    setState(() {
      cart.add(item);
    });
  }

  void placeOrder() {
    if (cart.isNotEmpty) {
      Order newOrder = Order(items: List.from(cart), dateTime: DateTime.now());
      widget.orderHistory.add(newOrder);

      // Clear the cart after placing the order
      setState(() {
        cart.clear();
      });

      // Optionally, you can show a confirmation dialog or navigate to order history.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order Placed'),
            content: Text('Your order has been placed successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Management'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Shop Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.shopItems.length,
              itemBuilder: (context, index) {
                Item item = widget.shopItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      addToCart(item);
                    },
                    child: Text('Add to Cart'),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                Item item = cart[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              placeOrder();
            },
            child: Text('Place Order'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // TODO: Add navigation to user profile page
              // For simplicity, we'll just print a message for now.
              print('Open user profile');
            },
          ),
        ],
      ),
      body: ProductList(),
    );
  }
}

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace this with your actual product list
    List<String> products = ['Product 1', 'Product 2', 'Product 3'];

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(products[index]),
          // TODO: Add navigation to product details page
          onTap: () {
            // For simplicity, we'll just print a message.
            print('Open product details for ${products[index]}');
          },
        );
      },
    );
  }
}
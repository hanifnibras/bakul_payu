import 'package:flutter/material.dart';
import 'edit_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce App'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()));
              print('Open user profile');
            },
          ),
        ],
      ),
      body: ProductList(),
    ));
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

import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'seller_side.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> products = ['Product 1', 'Product 2', 'Product 3'];
  List<String> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bakul Payu'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editProfile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              } else if (value == 'switchToSeller') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SellerSidePage(
                      shopItems: [
                        Item(name: 'Item 1', price: 10.0),
                      ],
                      orderHistory: [],
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'editProfile',
                child: Text('Edit Profile'),
              ),
              PopupMenuItem<String>(
                value: 'switchToSeller',
                child: Text('Switch to Seller Side'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterProducts(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CategoryButton(
                imagePath: 'assets/category1.png',
                category: 'Pakaian',
              ),
              CategoryButton(
                imagePath: 'assets/kerajinantangan.png',
                category: 'Kerajinan Tangan',
              ),
              CategoryButton(
                imagePath: 'assets/sembako.png',
                category: 'Sembako',
              ),
              CategoryButton(
                imagePath: 'oleholeh.png',
                category: 'Jajanan',
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredProducts[index]),
                  onTap: () {
                    print(
                        'Open product details for ${filteredProducts[index]}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where(
            (product) =>
                product.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }
}

class CategoryButton extends StatelessWidget {
  final String imagePath;
  final String category;

  CategoryButton({
    required this.imagePath,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Add logic to filter products based on category
        print('Selected category: $category');
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(imagePath),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(category),
        ],
      ),
    );
  }
}

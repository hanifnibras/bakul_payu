import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'seller_side.dart';

void main() {
  runApp(MyApp());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
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
    return PopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce App'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editProfile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              } else if (value == 'switchToSeller') {
                // TODO: Add logic to navigate to the SellerPage
                print('Switching to Seller side');
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
              CategoryButton(imagePath: 'assets/category1.png', category: 'Category 1'),
              CategoryButton(imagePath: 'assets/category2.png', category: 'Category 2'),
              CategoryButton(imagePath: 'assets/category3.png', category: 'Category 3'),
              CategoryButton(imagePath: 'assets/category4.png', category: 'Category 4'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredProducts[index]),
                  onTap: () {
                    print('Open product details for ${filteredProducts[index]}');
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
          .where((product) => product.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

class CategoryButton extends StatelessWidget {
  final String imagePath;
  final String category;

  CategoryButton({required this.imagePath, required this.category});

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


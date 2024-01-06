import 'package:bakul_payu/my_order.dart';
import 'package:bakul_payu/seller_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bakul_payu/edit_profile.dart';
import 'package:bakul_payu/seller_side.dart';
import 'package:bakul_payu/login.dart';
import 'package:flutter/services.dart';
import 'product_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = "allCat";

  @override
  Widget build(BuildContext context) {
    int currentPageIndex = 0;
    return WillPopScope(
        onWillPop: () async {
          // Show a confirmation dialog
          bool shouldClose = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Exit'),
                content: const Text('Do you want to close the application?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
          return shouldClose;
        },
        child: Scaffold(
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                    break;
                  case 1:
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MyOrder()),
                    );
                    break;
                  case 2:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SellerPage()),
                    );
                    break;
                  case 3:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()),
                    );
                    break;
                }
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.receipt_long),
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'My Orders',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.business),
                  icon: Icon(Icons.business_outlined),
                  label: 'Seller Page',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.account_circle),
                  icon: Icon(Icons.account_circle_outlined),
                  label: 'Profile',
                ),
              ],
            ),
            appBar: AppBar(
              title: const Text('Bakul Payu'),
              automaticallyImplyLeading: false,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(8.0), child: Text("Category")),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryButton(
                      imagePath: 'assets/pakaian.png',
                      category: 'pakaian',
                      title: "Pakaian",
                    ),
                    buildCategoryButton(
                      imagePath: 'assets/kerajinantangan.png',
                      category: 'kerajinan-tangan',
                      title: "Kerajinan Tangan",
                    ),
                    buildCategoryButton(
                      imagePath: 'assets/sembako.png',
                      category: 'sembako',
                      title: "Sembako",
                    ),
                    buildCategoryButton(
                      imagePath: 'assets/oleholeh.png',
                      category: 'jajanan',
                      title: "Jajanan",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      selectedCategory = "allCat";
                    }),
                    child: const Text('Show All Categories'),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Products"),
                const SizedBox(height: 10),
                StreamBuilder(
                    stream: (selectedCategory == "allCat" ||
                            selectedCategory.isEmpty)
                        ? FirebaseFirestore.instance
                            .collection('products')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('products')
                            .where('product_cat', isEqualTo: selectedCategory)
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
                            String productTitle =
                                productDetails['product_title'];
                            String sellerId = productDetails['seller_id'];
                            String productPriceString = productPrice.toString();
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                              cartItems: const [],
                                              productCat: productCat,
                                              productDesc: productDesc,
                                              productImgUrl: productImgUrl,
                                              productPrice: productPrice,
                                              productTitle: productTitle,
                                              sellerId: sellerId,
                                            )),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            bottomLeft: Radius.circular(16.0),
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
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 0, 0, 0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      productTitle,
                                                      style: const TextStyle(
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
                                ),
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
            ))));
  }

  Widget buildCategoryButton({
    required String imagePath,
    required String category,
    required String title,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
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
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}

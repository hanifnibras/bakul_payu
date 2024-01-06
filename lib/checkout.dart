import 'dart:io';
import 'package:bakul_payu/store_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final uid = FirebaseAuth.instance.currentUser?.uid;
  String imgDownloadUrl = "";
  String qrisLink = "";
  String shopeeLink = "";
  String rekening = "";

  @override
  void initState() {
    super.initState();
    fetchSellerData();
  }

  Future<void> fetchSellerData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.sellerId)
              .get();

      if (userSnapshot.exists) {
        setState(() {
          qrisLink = userSnapshot.data()?['qrisLink'] ?? '';
          shopeeLink = userSnapshot.data()?['shopeeLink'] ?? '';
          rekening = userSnapshot.data()?['rekening'] ?? '';
        });
      }
    } catch (error) {
      print('Error fetching seller name: $error');
    }
  }

  bool customerIsNotSeller() {
    if (widget.sellerId == uid) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      String filePath = 'images/transaction/$imageName';
      Reference storageReference = FirebaseStorage.instance.ref(filePath);
      String contentType = 'image/${imageName.split('.').last}';
      UploadTask uploadTask = storageReference.putFile(
        imageFile,
        SettableMetadata(contentType: contentType),
      );
      await uploadTask.whenComplete(() => null);
      String imgDownloadUrl = await storageReference.getDownloadURL();
      return imgDownloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> uploadDataToDatabase(String imageURL) async {
    try {
      List<Map<String, dynamic>> cartItemsData = widget.cartItems
          .map((cartItem) => {
                'productImgUrl': cartItem.productImgUrl,
                'productTitle': cartItem.productTitle,
                'productPrice': cartItem.productPrice,
                'quantity': cartItem.quantity,
              })
          .toList();
      await FirebaseFirestore.instance.collection('transactions').doc().set({
        'paymentImgUrl': imageURL,
        'buyerId': uid,
        'sellerId': widget.sellerId,
        'totalPrice': calculateTotalPrice(),
        'transactionStatus': "pending",
        'cartItems': cartItemsData
      });
      print('Firestore updated with image URL');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      String fileExtension = pickedImage.path.split('.').last;
      String imageName =
          "${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
      imgDownloadUrl = await uploadImageToStorage(
        File(pickedImage.path),
        imageName,
      );
      setState(() {});
      _showImageDialog();
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await storageReference.delete();
      print('Image deleted from storage');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Payment Proof'),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(
                    10.0), // Set the border radius as needed
                child: Image.network(
                  imgDownloadUrl,
                  fit: BoxFit.contain,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    deleteImageFromStorage(imgDownloadUrl);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    uploadDataToDatabase(imgDownloadUrl);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProcessPaymentPage(),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
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
              ExpansionTile(
                title: const Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/qris-logo.png'),
                    height: 30,
                  ),
                ),
                children: <Widget>[
                  if (qrisLink.isEmpty) ...[
                    const Text("QRIS Tidak tersedia di seller ini"),
                  ] else ...[
                    Image.network(
                      qrisLink,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: const Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/shopeepay-logo.png'),
                    height: 30,
                  ),
                ),
                children: <Widget>[
                  if (shopeeLink.isEmpty) ...[
                    const Text("ShopeePay Tidak tersedia di seller ini"),
                  ] else ...[
                    Image.network(
                      shopeeLink,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              ExpansionTile(
                title: const Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/bank-logo.png'),
                    height: 30,
                  ),
                ),
                children: <Widget>[
                  if (rekening.isEmpty) ...[
                    const Text("Nomor Rekening Tidak tersedia di seller ini"),
                  ] else ...[
                    Text(rekening)
                  ]
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
                  onPressed: () {
                    bool customerCheck = customerIsNotSeller();
                    if (customerCheck == true) {
                      pickImage(ImageSource.gallery);
                    } else if (customerCheck == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Invalid"),
                            content:
                                const Text("Seller cannot buy their own item."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ok"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
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

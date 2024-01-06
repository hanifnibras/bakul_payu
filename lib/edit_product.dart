// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProduct extends StatefulWidget {
  final String prodId;
  const EditProduct({
    super.key,
    required this.prodId,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  TextEditingController titleController = TextEditingController();
  TextEditingController productDescController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String itemCategory = "pakaian";
  String productTitle = "";
  int productPrice = 0;
  String productDesc = "";

  final Map<String, String> itemCategoryOptions = {
    "pakaian": "Pakaian",
    "kerajinan-tangan": "Kerajinan Tangan",
    "sembako": "Sembako",
    "jajanan": "Jajanan",
  };

  Future<String> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      String filePath = 'images/product/$imageName';
      Reference storageReference = FirebaseStorage.instance.ref(filePath);
      String contentType = 'image/${imageName.split('.').last}';
      UploadTask uploadTask = storageReference.putFile(
        imageFile,
        SettableMetadata(contentType: contentType),
      );
      await uploadTask.whenComplete(() => null);
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> updateImgURL(String imageURL) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.prodId)
          .update({'product_img_url': imageURL});
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
      String downloadURL = await uploadImageToStorage(
        File(pickedImage.path),
        imageName,
      );
      await updateImgURL(downloadURL);
      setState(() {});
    }
  }

  Future<void> _fetchProdData() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.prodId)
            .get();
    final prodData = snapshot.data();
    if (prodData != null) {
      setState(() {
        itemCategory = prodData['product_cat'];
        productTitle = prodData['product_title'];
        productPrice = prodData['product_price'];
        productDesc = prodData['product_desc'];
        titleController = TextEditingController(text: productTitle);
        priceController = TextEditingController(text: productPrice.toString());
        productDescController = TextEditingController(text: productDesc);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProdData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakul Payu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.prodId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (!snapshot.hasData) {
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
                    final prodData = snapshot.data!;
                    String productImgUrl = prodData['product_img_url'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          productImgUrl,
                          fit: BoxFit.contain,
                          width: screenSize.width,
                          height:
                              screenSize.height - screenSize.height * 50 / 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              pickImage(ImageSource.gallery);
                            },
                            child: const Text('Change Image'),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Ganti Judul Produk:',
                          style: TextStyle(fontSize: 18),
                        ),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: 'Ketik Nama Produk Baru.',
                          ),
                        ),
                        const Text(
                          'Ganti Harga Produk:',
                          style: TextStyle(fontSize: 18),
                        ),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Ketik Harga Baru.',
                          ),
                        ),
                        const Text(
                          'Ganti Deskripsi Produk:',
                          style: TextStyle(fontSize: 18),
                        ),
                        TextField(
                          controller: productDescController,
                          decoration: const InputDecoration(
                            hintText: 'Ketik Deskripsi Baru.',
                          ),
                        ),
                        const Text("Select item category"),
                        DropdownButton<String>(
                          value: itemCategory,
                          onChanged: (value) {
                            setState(() {
                              itemCategory = value!;
                            });
                          },
                          items: itemCategoryOptions.keys
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(itemCategoryOptions[value]!),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;
                              String newTitle = titleController.text.trim();
                              int? newPrice =
                                  int.tryParse(priceController.text.trim());
                              String newDesc =
                                  productDescController.text.trim();
                              if (newTitle.isNotEmpty &&
                                  newPrice != null &&
                                  newDesc.isNotEmpty) {
                                try {
                                  await firestore
                                      .collection("products")
                                      .doc(widget.prodId)
                                      .update({
                                    'product_title': newTitle,
                                    'product_price': newPrice,
                                    'product_desc': newDesc,
                                    'product_cat': itemCategory
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Data Saved'),
                                        content: const Text(
                                            'Item information has been updated'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } catch (e) {
                                  if (e is FirebaseException) {
                                    print('Firebase error: ${e.message}');
                                  } else {
                                    print('Error: $e');
                                  }
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Missing Information'),
                                      content: const Text(
                                          'Please fill in all the required fields.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text('Save Data'),
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

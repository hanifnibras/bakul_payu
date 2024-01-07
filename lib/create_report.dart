import 'dart:io';

import 'package:bakul_payu/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateReport extends StatefulWidget {
  final String sellerId;
  final String? customerId;
  final String sellerName;
  const CreateReport(
      {super.key,
      required this.sellerId,
      this.customerId,
      required this.sellerName});

  @override
  State<CreateReport> createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  final TextEditingController _reportMessageController =
      TextEditingController();
  String imgUrl = '';

  Future<String> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      String filePath = 'images/report/$imageName';

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

  Future<String> pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      String fileExtension = pickedImage.path.split('.').last;
      String imageName =
          "${DateTime.now().millisecondsSinceEpoch}.$fileExtension";
      String downloadURL = await uploadImageToStorage(
        File(pickedImage.path),
        imageName,
      );
      setState(() {});
      return downloadURL;
    } else {
      return "";
    }
  }

  Future<void> uploadDataToDatabase(String imageURL) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc().set({
        'reportImgUrl': imageURL,
        'reportMessage': _reportMessageController.text.trim(),
        'customerId': widget.customerId,
        'sellerId': widget.sellerId,
        'reportStatus': "active",
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.sellerId)
          .update({
        'storeSuspension': 'pending',
      });
      popUpTerimaKasih();
      print('Firestore updated with image URL');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> popUpTerimaKasih() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Laporan Terkirim"),
          content: const Text(
              "Terima kasih atas laporan anda. Laporan anda akan segera kami tindak lanjuti."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            0,
          ),
          child: Column(
            children: [
              Text(
                "Report Seller ${widget.sellerName}'s Store",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _reportMessageController,
                decoration: const InputDecoration(
                  labelText: 'Tulis Laporan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (imgUrl.isNotEmpty) ...[
                Image.network(
                  imgUrl,
                  fit: BoxFit.contain,
                  width: screenSize.width,
                  height: screenSize.height - screenSize.height * 50 / 100,
                ),
              ],
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  String uploadedImgUrl = await pickImage(ImageSource.gallery);
                  setState(() {
                    imgUrl = uploadedImgUrl;
                  });
                },
                child: const Text('Upload Bukti Gambar'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (imgUrl.isNotEmpty &&
                      _reportMessageController.text.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Konfirmasi Laporan"),
                          content: Text(
                              "Apakah anda yakin untuk melaporkan ${widget.sellerName}'s Store"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Tidak"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                uploadDataToDatabase(imgUrl);
                              },
                              child: const Text("Ya"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "Mohon isi kolom pesan dan upload bukti gambar"),
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
                child: const Text('Kirim Laporan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

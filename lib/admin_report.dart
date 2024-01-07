// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  Future<String> _fetchSellerName(String sellerId) async {
    late String sellerName;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();
      if (snapshot.exists) {
        sellerName = snapshot.data()?['name'] ?? '';
      }
      return sellerName;
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  Future<String> _fetchSellerSuspensionStatus(String sellerId) async {
    late String sellerName;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();
      if (snapshot.exists) {
        sellerName = snapshot.data()?['storeSuspension'] ?? '';
      }
      return sellerName;
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  Future<String> _fetchCustomerData(String customerId) async {
    late String customerName;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(customerId)
              .get();
      if (snapshot.exists) {
        customerName = snapshot.data()?['name'] ?? '';
      }
      return customerName;
    } catch (error) {
      print('Error fetching seller name: $error');
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bakul Payu Admin"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Report List',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('reports')
                      .where('reportStatus', isEqualTo: "active")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No report is found',
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      final List<QueryDocumentSnapshot> reports =
                          snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final reportDetails =
                              reports[index].data() as Map<String, dynamic>;
                          String customerId = reportDetails['customerId'];
                          String sellerId = reportDetails['sellerId'];
                          String reportImgUrl = reportDetails['reportImgUrl'];
                          String reportMessage = reportDetails['reportMessage'];
                          String reportId = reports[index].id;
                          return FutureBuilder(
                            future: Future.wait([
                              _fetchSellerName(sellerId),
                              _fetchCustomerData(customerId),
                              _fetchSellerSuspensionStatus(sellerId)
                            ]),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshots) {
                              if (snapshots.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshots.hasError) {
                                return Text('Error: ${snapshots.error}');
                              }
                              String sellerName = snapshots.data?[0] ?? '';
                              String customerName = snapshots.data?[1] ?? '';
                              String suspensionStatus =
                                  snapshots.data?[2] ?? '';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Seller: $sellerName's Store"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Customer: $customerName"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text("Bukti Foto"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Image.network(
                                    reportImgUrl,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Pesan Laporan:"),
                                  Text(reportMessage),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      if (suspensionStatus != "suspended") ...[
                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Hapus Laporan'),
                                                    content: const Text(
                                                        'Anda yakin ingin menghapus laporan ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(sellerId)
                                                                .update({
                                                              'storeSuspension':
                                                                  'clear'
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'reports')
                                                                .doc(reportId)
                                                                .update({
                                                              'reportStatus':
                                                                  'inactive'
                                                            });
                                                          } catch (e) {
                                                            print(
                                                                'Error updating storeSuspension: $e');
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Hapus'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Hapus Laporan",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Batalkan Suspensi'),
                                                    content: const Text(
                                                        'Anda yakin ingin membatalkan suspensi?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(sellerId)
                                                                .update({
                                                              'storeSuspension':
                                                                  'clear'
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'reports')
                                                                .doc(reportId)
                                                                .update({
                                                              'reportStatus':
                                                                  'inactive'
                                                            });
                                                          } catch (e) {
                                                            print(
                                                                'Error updating storeSuspension: $e');
                                                          }
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Hapus'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Batalkan Suspensi",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (suspensionStatus == "pending") ...[
                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Berikan Peringatan 1'),
                                                    content: const Text(
                                                        'Anda yakin ingin memberikan peringatan 1?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(sellerId)
                                                                .update({
                                                              'storeSuspension':
                                                                  'firstWarning'
                                                            });
                                                          } catch (e) {
                                                            print(
                                                                'Error updating storeSuspension: $e');
                                                          }
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Berikan'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Beri Peringatan 1",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ] else if (suspensionStatus ==
                                          'firstWarning') ...[
                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Berikan Peringatan 2'),
                                                    content: const Text(
                                                        'Anda yakin ingin memberikan peringatan 2?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(sellerId)
                                                                .update({
                                                              'storeSuspension':
                                                                  'secondWarning'
                                                            });
                                                          } catch (e) {
                                                            print(
                                                                'Error updating storeSuspension: $e');
                                                          }
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Berikan'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Beri Peringatan 2",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ] else if (suspensionStatus ==
                                          'secondWarning') ...[
                                        Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Suspend Seller'),
                                                    content: const Text(
                                                        'Anda yakin ingin me-suspend Seller?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(sellerId)
                                                                .update({
                                                              'storeSuspension':
                                                                  'suspended'
                                                            });
                                                          } catch (e) {
                                                            print(
                                                                'Error updating storeSuspension: $e');
                                                          }
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Berikan'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "Suspend Seller",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Divider(
                                    height: 20,
                                    thickness: 2,
                                  ),
                                ],
                              );
                            },
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
          ),
        ),
      ),
    );
  }
}

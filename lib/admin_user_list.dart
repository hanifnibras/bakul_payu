import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({super.key});

  @override
  State<AdminUserList> createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  Map<String, String> userTypes = {}; // Map to store user types for each user

  Map<String, String> userTypeDropdown = {
    'user': 'User',
    'admin': 'Admin',
  };

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
                'User List',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No user is found',
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> users =
                        snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userDetails =
                            users[index].data() as Map<String, dynamic>;
                        String userName = userDetails['name'];
                        String uid = users[index].id;
                        String userType =
                            userTypes[uid] ?? userDetails['userType'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(userName),
                                const SizedBox(
                                  width: 10,
                                ),
                                DropdownButton<String>(
                                  value: userType,
                                  onChanged: (value) {
                                    setState(() {
                                      userTypes[uid] = value!;
                                      // Update userType in Firestore
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .update({'userType': value});
                                    });
                                  },
                                  items: userTypeDropdown.keys
                                      .map<DropdownMenuItem<String>>(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(userTypeDropdown[value]!),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("id: $uid"),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 4,
                              thickness: 1,
                            )
                          ],
                        );
                      },
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

import 'package:bakul_payu/chat_room.dart';
import 'package:bakul_payu/edit_profile.dart';
import 'package:bakul_payu/homepage.dart';
import 'package:bakul_payu/my_order.dart';
import 'package:bakul_payu/seller_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  int currentPageIndex = 3;
  bool myOrderNotification = false;
  bool sellerPageNotification = false;

  Future<void> myOrderDotNotification() async {
    if (uid != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('buyerId', isEqualTo: uid)
              .where('transactionStatus',
                  whereIn: ["confirmed", "finished", "declined"]).get();
      setState(() {
        myOrderNotification = snapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> sellerPageDotNotification() async {
    if (uid != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('sellerId', isEqualTo: uid)
              .where('transactionStatus', whereIn: ["pending"]).get();
      setState(() {
        sellerPageNotification = snapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> sellerSuspensionNotification() async {
    late String suspensionStatus;
    if (uid != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      suspensionStatus = snapshot.data()?['storeSuspension'] ?? "";
      if (suspensionStatus != 'clear') {
        setState(() {
          sellerPageNotification = true;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchUserName(
      String userId, String chatId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      final userData = snapshot.data();
      final unread = await _fetchUnreadStatus(userId, chatId);

      return {
        'name': userData?['name'] ?? 'Unknown User',
        'unread': unread,
      };
    } catch (e) {
      print("Error fetching user name: $e");
      return {'name': 'Unknown User', 'unread': false};
    }
  }

  Future<bool> _fetchUnreadStatus(String userId, String chatId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('messageList')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final latestMessage = querySnapshot.docs.first.data();
        return latestMessage['unread'] ?? false;
      }

      return false;
    } catch (e) {
      print("Error fetching unread status: $e");
      return false;
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(conversationId)
          .collection('messageList')
          .where('receiverId', isEqualTo: uid)
          .where('unread', isEqualTo: true)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in snapshot.docs) {
          document.reference.update({'unread': false});
        }
      });
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    myOrderDotNotification();
    sellerPageDotNotification();
    sellerSuspensionNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  MaterialPageRoute(builder: (context) => const SellerPage()),
                );
                break;
              case 3:
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChatListPage()),
                );
                break;
              case 4:
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
                break;
            }
          },
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            const NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            if (myOrderNotification == true) ...[
              const NavigationDestination(
                selectedIcon: Icon(Icons.receipt_long),
                icon: Badge(
                  label: Text('!'),
                  child: Icon(Icons.receipt_long_outlined),
                ),
                label: 'My Orders',
              ),
            ] else ...[
              const NavigationDestination(
                selectedIcon: Icon(Icons.receipt_long),
                icon: Icon(Icons.receipt_long_outlined),
                label: 'My Orders',
              ),
            ],
            if (sellerPageNotification == true) ...[
              const NavigationDestination(
                selectedIcon: Icon(Icons.business),
                icon: Badge(
                  label: Text('!'),
                  child: Icon(Icons.business_outlined),
                ),
                label: 'Seller Page',
              ),
            ] else ...[
              const NavigationDestination(
                selectedIcon: Icon(Icons.business),
                icon: Icon(Icons.business_outlined),
                label: 'Seller Page',
              )
            ],
            const NavigationDestination(
              selectedIcon: Icon(Icons.message),
              icon: Icon(Icons.message_outlined),
              label: 'Chats',
            ),
            const NavigationDestination(
              selectedIcon: Icon(Icons.account_circle),
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text('Bakul Payu'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .where('participants', arrayContains: uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("You have not start any message"),
                        );
                      }
                      final conversations = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversationData = conversations[index].data();
                          final participants =
                              conversationData['participants'] as List?;
                          final chatId = conversations[index].id;
                          if (participants != null) {
                            final otherParticipantId =
                                participants.firstWhere((id) => id != uid);
                            return ListTile(
                              title: FutureBuilder(
                                future:
                                    _fetchUserName(otherParticipantId, chatId),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, dynamic>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  final userName = snapshot.data?['name'];
                                  final isUnread =
                                      snapshot.data?['unread'] ?? false;
                                  return Row(
                                    children: [
                                      Text(userName ?? 'Unknown User'),
                                      if (isUnread)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              onTap: () {
                                markMessagesAsRead(chatId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatRoom(
                                      receiverId: otherParticipantId,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                ],
              )),
        ));
  }
}

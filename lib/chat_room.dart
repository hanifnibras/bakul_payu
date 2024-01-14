import 'dart:io';
import 'package:bakul_payu/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoom extends StatefulWidget {
  final String receiverId;
  const ChatRoom({super.key, required this.receiverId});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String senderName = "";
  String receiverName = "";
  String chatId = "";
  final uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController chatInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSenderName();
    _fetchReceiverName();
    Future.delayed(Duration.zero, () {
      ownSelfCheck();
    });
    getChatId(uid!, widget.receiverId);
  }

  Future<void> fetchSenderName() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          senderName = userData['name'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching sender name: $e");
    }
  }

  Future<void> _fetchReceiverName() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverId)
              .get();
      final userData = snapshot.data();
      if (userData != null) {
        setState(() {
          receiverName = userData['name'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching receiver name: $e");
    }
  }

  void ownSelfCheck() {
    if (uid == widget.receiverId) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Invalid"),
            content: const Text("You cannot text yourself"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  void getChatId(String senderId, String receiverId) {
    List<String> idList = [senderId, receiverId];
    idList.sort();
    String createdId = idList.join("-");
    chatId = createdId;
  }

  Future<String> uploadImageToStorage(File imageFile, String imageName) async {
    try {
      String filePath = 'images/message/$imageName';
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

  void sendImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('messageList')
          .add({
        'senderId': uid,
        'receiverId': widget.receiverId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'unread': true
      });
    } catch (e) {
      print("Error sending image: $e");
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
      setState(() {});
      sendImage(downloadURL);
    }
  }

  void sendMessage() async {
    String messageText = chatInputController.text.trim();
    if (messageText.isNotEmpty) {
      try {
        String currentUserId = uid ?? '';
        List<String> participants = [currentUserId, widget.receiverId];
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('messageList')
            .add({
          'senderId': uid,
          'receiverId': widget.receiverId,
          'messageText': messageText,
          'timestamp': FieldValue.serverTimestamp(),
          'unread': true
        });
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .set({
          'participants': participants,
        }, SetOptions(merge: true));
        chatInputController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(receiverName),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(chatId)
                    .collection('messageList')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("Start your conversation with $receiverName"),
                    );
                  }
                  final messages = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data();
                      String senderId = messageData['senderId'];
                      String messageText = messageData['messageText'] ?? '';
                      String imageUrl = messageData['imageUrl'] ?? '';
                      bool isCurrentUser = senderId == uid;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: isCurrentUser ? 50.0 : 8.0,
                          right: isCurrentUser ? 8.0 : 50.0,
                          top: 4.0,
                          bottom: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isCurrentUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (messageText.isNotEmpty) ...[
                                Text(
                                  isCurrentUser ? 'You' : receiverName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  messageText,
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ] else if (imageUrl.isNotEmpty) ...[
                                Text(
                                  isCurrentUser ? 'You' : receiverName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Image.network(
                                  imageUrl,
                                  width: 200.0,
                                  height: 150.0,
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatInputController,
                      decoration: const InputDecoration(
                        hintText: 'Send your message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      await pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
    );
  }
}

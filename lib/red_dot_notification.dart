import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RedDotNotification extends StatefulWidget {
  const RedDotNotification({super.key});

  @override
  State<RedDotNotification> createState() => _RedDotNotificationState();
}

class _RedDotNotificationState extends State<RedDotNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  void redDotNotification() {}
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

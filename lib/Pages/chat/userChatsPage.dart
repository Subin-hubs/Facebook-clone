import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/FRIENDS/friendpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class chatsPage extends StatefulWidget {
  const chatsPage({super.key});

  @override
  State<chatsPage> createState() => _chatsPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class _chatsPageState extends State<chatsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.back),
              Icon(Icons.person),
            ],
          )
        ],
      ),
    ));
  }
}

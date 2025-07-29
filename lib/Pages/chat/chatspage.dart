import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chats extends StatefulWidget {
  const chats({super.key});

  @override
  State<chats> createState() => _chatsState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> fetchUsers() async {

    final snapshot = await _firestore.collection("users").get();
    final fetched = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': data['fname'] ?? '', // ✅ corrected key
        'imageUrl': data['imageUrl'] ?? '',
        'isFriend': data['isFriend'] ?? false,
        'mutuals': List<String>.from(data['mutuals'] ?? []),
      };
    }).toList();
}

class _chatsState extends State<chats> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("messenger",style: TextStyle(
                    color: Colors.black,
                    fontSize: 20
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 160),
                  child: Image(image: AssetImage("assests/messangericon.png"),height: 35,width: 35,),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SearchBar(
                hintText: "Ask Meta AI or Search",

            ),
            )
          ],
        ),
      )
    ));
  }
}

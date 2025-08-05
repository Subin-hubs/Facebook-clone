import 'package:facebok/Pages/chat/userChatsPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class chats extends StatefulWidget {
  const chats({super.key});

  @override
  State<chats> createState() => _chatsState();
}

class _chatsState extends State<chats> {
  late Stream<QuerySnapshot> friendsStream;

  @override
  void initState() {
    super.initState();
    friendsStream = FirebaseFirestore.instance
        .collection('users')
        .snapshots(); // Removed where clause
  }

  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Decoding error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back_ios, color: Colors.black),
                  Text("Messenger", style: TextStyle(color: Colors.black, fontSize: 20)),
                  Icon(Icons.add, color: Colors.black),
                ],
              ),
            ),

            // Search Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Ask Meta AI or Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),

            // Friend List
            StreamBuilder<QuerySnapshot>(
              stream: friendsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No friends found", style: TextStyle(color: Colors.black54)),
                  );
                }

                final docs = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        final fname = data['fname'] ?? '';
                        final lname = data['lname'] ?? '';
                        final email = data['email'] ?? 'No Email';
                        final fullName = "$fname $lname".trim();
                        final imageData = decodeBase64Image(data['ppimage']);

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: imageData != null ? MemoryImage(imageData) : null,
                            child: imageData == null
                                ? const Icon(Icons.person, color: Colors.black)
                                : null,
                          ),
                          title: Text(
                            fullName.isEmpty ? 'Unknown User' : fullName,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(email, style: const TextStyle(color: Colors.black54)),
                          trailing: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>chatsPage(friendName: '', friendUid: '',)));
                          },
                        );
                      }

                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

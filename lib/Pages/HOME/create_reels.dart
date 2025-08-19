import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../mainpage.dart';


class CreateReels extends StatefulWidget {
  const CreateReels({super.key});

  @override
  State<CreateReels> createState() => _CreateReelsState();
}

class _CreateReelsState extends State<CreateReels> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? base64Image;


  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 70,
      );
      if (compressed != null) {
        setState(() {
          base64Image = base64Encode(compressed);
        });
      }
    }
  }


  Future<void> addPost(String description, String? imageData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reels')
        .doc();

    await postsRef.set({
      'text': description,
      'image': imageData ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy':[],
      'userId': user.uid,
    });
  }


  Future<void> handlePost() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty && base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reels cannot be empty")),
      );
      return;
    }

    await addPost(description, base64Image);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reels uploaded successfully")),
    );

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Mainpage(0,false)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Reels"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),

          actions: [
            TextButton(
              onPressed: handlePost,
              child: const Text("Post", style: TextStyle(color: Colors.black)),
            ),
          ],

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (base64Image != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Image Preview", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Image.memory(
                      base64Decode(base64Image!),
                      height: 150,
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () => pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () => pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
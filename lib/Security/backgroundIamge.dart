import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/mainpage.dart';

class backgroundImage extends StatefulWidget {
  @override
  _backgroundImageState createState() => _backgroundImageState();
}

class _backgroundImageState extends State<backgroundImage> {
  Uint8List? imageBytes;
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;

  Future<void> pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 70,
      );
      if (compressed != null) {
        final Uint8List imageData = Uint8List.fromList(compressed);
        final String base64Image = base64Encode(imageData);

        setState(() => imageBytes = imageData);
        await uploadToFirestore(base64Image);
      }
    }
  }

  Future<void> uploadToFirestore(String base64Image) async {
    try {
      setState(() => isLoading = true);
      final user = _auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'baclgroundImage': base64Image,
        'hasUploadedPhoto': true,
        'profileStep': 3,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Background photo uploaded to database!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateUserProfile({bool skipped = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'hasUploadedPhoto': !skipped,
      'profileStep': 3,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(skipped ? 'Profile skipped!' : 'Profile updated!')),
    );
  }

  Widget buildImageCircle() {
    return GestureDetector(
      onTap: showImageSourceSelector,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: imageBytes != null
              ? Image.memory(imageBytes!, fit: BoxFit.cover)
              : Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Add Your Background Image',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Upload a Background picture to complete your account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 40),
            buildImageCircle(),
            SizedBox(height: 20),
            Text(
              'Upload a photo highlight yourself.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Mainpage(0,false)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Text('Complete Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.white)),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Mainpage(0,false)));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text('Skip',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
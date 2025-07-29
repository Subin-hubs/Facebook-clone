import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Market_Sell extends StatefulWidget {
  const Market_Sell({super.key});

  @override
  State<Market_Sell> createState() => _Market_SellState();
}

class _Market_SellState extends State<Market_Sell> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> convertImageToBase64(File imageFile) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 60,
      );

      if (compressedBytes == null) return null;
      return base64Encode(compressedBytes);
    } catch (e) {
      print(' Base64 conversion error: $e');
      return null;
    }
  }

  Future<void> _uploadProduct() async {
    if (_imageFile == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields & select image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final base64Image = await convertImageToBase64(_imageFile!);
      if (base64Image == null) {
        throw Exception("Image conversion failed.");
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final productData = {
        'name': nameController.text.trim(),
        'price': priceController.text.trim(),
        'description': descriptionController.text.trim(),
        'image': base64Image,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('marketplace')
          .add(productData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Product uploaded successfully')),
      );

      // Reset fields
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      setState(() => _imageFile = null);
    } catch (e) {
      print(' Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Failed to upload product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Tap to select image')),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _uploadProduct,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

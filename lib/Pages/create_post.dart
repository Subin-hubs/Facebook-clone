import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/Home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'mainpage.dart';

class create_post extends StatefulWidget {
  const create_post({super.key});

  @override
  State<create_post> createState() => _create_postState();
}

class _create_postState extends State<create_post> {

  String? base64Images;

  TextEditingController Description = TextEditingController();
  Future<void> create_post() async {
    try{
      await FirebaseFirestore.instance.collection('Post').add({
        'Description': Description.text,
        'image': base64Images,
      });
    }catch(e){
      print("Error: $e");
    }
  }
  Future<void> pickImage(ImageSource source) async{
    final picker=ImagePicker();
    final pickedFile= await picker.pickImage(source: source,imageQuality: 70);

    if (pickedFile != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 70,
      );
      if (compressed != null) {
        setState(() {
          base64Images = base64Encode(compressed);
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("X"),
            Text("Create post"),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Mainpage()));
              create_post();
            }, child: Text("post")),
            if(base64Images!=null)
              Column(
                children: [
                  const SizedBox(height: 10,),
                  const Text("Preview"),
                  Image.memory(base64Decode(base64Images!), height: 150,),
                ],
              )
          ],
        ),
        TextFormField(
          controller: Description,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: (){
              pickImage(ImageSource.camera);
            },
                icon: Icon(Icons.camera_alt_outlined)),
            IconButton(onPressed: (){
              pickImage(ImageSource.gallery);
            }, icon: Icon(Icons.photo)),
          ],
        ),

      ],
      ),
    ));
  }
}

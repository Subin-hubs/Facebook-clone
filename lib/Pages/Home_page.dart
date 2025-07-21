import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'create_post.dart';

class home_pages extends StatefulWidget {
  const home_pages({super.key});

  @override
  State<home_pages> createState() => _home_pagesState();
}

class _home_pagesState extends State<home_pages> {


  Stream<List<Map<String, dynamic>>> fetchPosts() {
    return FirebaseFirestore.instance
        .collection('Post') // Make sure this matches your collection name
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot doc) {
        return {
          'Title': doc['Title'],
          'Description': doc['Description'],
          'image': doc['image'],
        };
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Column(
          children: [
            // Top Header Row (facebook + icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "facebook",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image(
                        image: AssetImage("assests/add.png"),
                        height: 40,
                        width: 40,
                      ),
                    ),
                    Image(
                      image: AssetImage("assests/copy.png"),
                      height: 25,
                      width: 25,
                    ),
                    Image(
                      image: AssetImage("assests/messanger.png"),
                      height: 25,
                      width: 25,
                    ),
                  ],
                ),

              ],
            ),

            const SizedBox(height: 15),

            // What's on your mind box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Profile Picture
                  // const CircleAvatar(
                  //   radius: 22,
                  //   backgroundImage: AssetImage("assests/profile.jpg"), // Replace with your image
                  // ),
                  const SizedBox(width: 10),

                  GestureDetector(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>create_post()));
                  },
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Image icon
                  IconButton(
                    icon:  GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>create_post()));
                        },
                        child: Icon(Icons.image_outlined, color: Colors.grey)),
                    onPressed: () {
                      // Open image picker
                    },
                  ),
                ],
              ),
            ),

            // Add Divider
            const Divider(thickness: 4),
          ],
        ),
      ),
    );
  }
}
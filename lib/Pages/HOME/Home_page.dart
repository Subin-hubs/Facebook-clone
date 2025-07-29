import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/HOME/widgets/story.dart';
import 'package:facebok/Pages/chat/chatspage.dart';
import 'package:facebok/Pages/mainpage.dart';
import 'package:facebok/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_post.dart';
import 'dart:developer';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  String currentUserId = "ziLUSzisNnViB8vO2iDPEFd8zgf1";

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List a= ["1","2","3"];
  Future<void> Like(String postId,int currentLikeCount,bool liked,List likedByUserId,String postsUserId) async {
   try{
     final user = _auth.currentUser;
     log("got list"+likedByUserId.toString());
     log("got list"+user.toString());
     final postsRef = _firestore
         .collection('users')
         .doc(postsUserId)
         .collection('posts')
         .doc(postId);
     List finalLikedByUsersId = [];
     if(likedByUserId.length==0){
       finalLikedByUsersId.add(user!.uid);
     }else{
       for(int i =0;i<likedByUserId.length;i++){
         finalLikedByUsersId.add(likedByUserId[i]);
         if(liked==true){
           finalLikedByUsersId.remove(user!.uid);
         }else{
           finalLikedByUsersId.add(user!.uid);
         }
       }
     }
     await postsRef.update({
       'likes': liked==true?currentLikeCount-1:currentLikeCount + 1,
       'likedBy':finalLikedByUsersId
     });
   }catch(e){
     print(e);
   }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Column(
          children: [
            // 🔵 Facebook Top Bar
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
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CreatePost()));
                      },
                      child: Image.asset("assests/add.png", height: 40, width: 40),
                    ),
                    SizedBox(width: 10),
                    Image.asset("assests/copy.png", height: 25, width: 25),
                    SizedBox(width: 10),
                    GestureDetector(onTap:(){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => chats()));
                    },child: Image.asset("assests/messanger.png", height: 20, width: 25)),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CreatePost()));
                      },
                      child: const Text(
                        "What's on your mind?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => Mainpage()));
                    },
                  ),
                ],
              ),
            ),

            const Divider(thickness: 4),

            // 📰 Post Feed
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts available"));
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      List likedByUsersId = [];

                     if(post['likedBy'].length==0){}else{
                       for(int i =0;i<post['likedBy'].length;i++){

                         if(likedByUsersId.contains(post['likedBy'][i])){}else{
                            likedByUsersId.add(post['likedBy'][i]);
                         }

                       }
                     }
                      bool liked = likedByUsersId.contains(_auth.currentUser!.uid);
                     log(liked.toString());
                      final text = post['text'] ?? '';
                      final image = post['image'];
                      final timestamp = post['timestamp'] as Timestamp?;
                      final userId = post['userId'];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchUserData(userId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (userSnapshot.hasError) {
                            return const Center(child: Text("Error fetching user data"));
                          }

                          final userData = userSnapshot.data ?? {};
                          final userName = userData['fname'] ?? 'Anonymous';
                          final profilePic = userData['profile_picture'] ?? '';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // CircleAvatar(
                                      //   radius: 20,
                                      //   backgroundImage: profilePic.isNotEmpty
                                      //       ? NetworkImage(profilePic)
                                      //       : const AssetImage('assets/default_profile.png') as ImageProvider,
                                      // ),
                                      const SizedBox(width: 10),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  if (timestamp != null)
                                    Text(
                                      formatTimestamp(timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 6),

                                  Text(
                                    text,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),

                                  if (image != null && image.toString().isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:  [
                                        GestureDetector(
                                          onTap: () {
                                              log(likedByUsersId.toString());
                                            Like(post.id,post['likes'],liked,likedByUsersId,post['userId']);
                                          },
                                            child: Icon(Icons.thumb_up_alt_rounded,color:liked==true? Colors.blueAccent:Colors.red,),
                                        ),
                                        Icon(Icons.comment),
                                        Icon(Icons.ios_share_outlined),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

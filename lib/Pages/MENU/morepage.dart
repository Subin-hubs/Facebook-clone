import 'dart:convert';

import 'package:facebok/Pages/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Security/login_page.dart';
import 'package:facebok/Pages/HOME/Home_page.dart';
import 'package:facebok/Pages/REELS/Reels.dart';

import 'ProfilePage.dart';

class more extends StatefulWidget {
  const more({super.key});

  @override
  State<more> createState() => _moreState();
}

class _moreState extends State<more> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => loginPage()));
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: userData == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧭 Top Menu Header
              Row(
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.search, color: Colors.black),
                  SizedBox(width: 16),
                  Icon(Icons.settings, color: Colors.black),
                ],
              ),
              SizedBox(height: 24),

              // 🙍‍♂️ User Profile Info
              GestureDetector(

                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                }
              ,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: userData!['ppimage'] != null
                          ? MemoryImage(base64Decode(userData!['ppimage']))
                          : AssetImage("assests/defaultimg.png") as ImageProvider,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${userData!['fname'] ?? 'First'} ${userData!['lname'] ?? 'Last'}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "View your profile",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // 🚀 Navigation Buttons
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: [
                  MenuButton(
                    icon: Icons.home_outlined,
                    label: "Home",
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Mainpage(0,false)),
                    ),
                  ),
                  MenuButton(
                    icon: Icons.movie_outlined,
                    label: "Reels",
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Mainpage(1,true)),
                    ),
                  ),
                  MenuButton(
                    icon: Icons.person_outline,
                    label: "Profile",
                    onTap: () {}, // Add logic
                  ),
                  MenuButton(
                    icon: Icons.shopping_cart_outlined,
                    label: "Marketplace",
                    onTap: () {}, // Add logic
                  ),
                ],
              ),

              Spacer(),

              // 🔓 Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => loginPage()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 📱 Reusable Button Widget
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blue[600]),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
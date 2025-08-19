import 'dart:developer';
import 'package:facebok/Security/forgetpassword.dart';
import 'package:facebok/Security/signupPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/HOME/Home_page.dart';
import '../Pages/mainpage.dart';

class loginPage extends StatefulWidget {
   loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  int _tabTextIndexSelected = 0; 

  Future<User?> loginUser() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _pref.setString('email', emailController.text);
      _pref.setString('password', passwordController.text);

      final User? user = userCredential.user;

      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      final userData = userSnapshot.data() as Map<String, dynamic>?;
      log("User data: $userData");

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Login successful");

      if (_tabTextIndexSelected == 0) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Mainpage(0,false)));
      } else {

      }

      return user;

    } catch (e, stacktrace) {
      print("Login Error: $e");
      print("StackTrace: $stacktrace");
      Fluttertoast.showToast(msg: "Invalid username or password");

      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 100),
            Center(
              child: Image.asset("assests/facebookicon.png", height: 60, width: 60),
            ),
             SizedBox(height: 90),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Mobile number or email",
                filled: true,
                fillColor: Colors.grey.shade100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:  BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:  BorderSide(color: Colors.grey),
                ),
              ),
            ),
             SizedBox(height: 10),

            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.grey.shade100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:  BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:  BorderSide(color: Colors.grey),
                ),
              ),
            ),
             SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loginUser,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ?  Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    :  Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Log in",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  forgetPassword()));
                },
                child:  Text(
                  "Forgot password?",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/6,),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  SignupPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:  BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Create new account",
                      style: TextStyle(
                        color: Colors.blueAccent.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
             SizedBox(height: 10),
             Center(child: Text("Meta", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/mainpage.dart';
import 'package:facebok/Security/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Pages/HOME/Home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateFriendSuggestions(String uid) async {
    final newUserDoc = _firestore.collection('users').doc(uid);
    final allUsers = await _firestore.collection('users').get();

    for (var user in allUsers.docs) {
      if (user.id == uid) continue;

      final mutualFriends = <String>[];

      final existingFriends = await _firestore
          .collection('friends')
          .doc(user.id)
          .collection('list')
          .get();

      for (var f in existingFriends.docs) {
        final isMutual = await _firestore
            .collection('friends')
            .doc(uid)
            .collection('list')
            .doc(f.id)
            .get();

        if (isMutual.exists) mutualFriends.add(f.id);
      }

      if (mutualFriends.isNotEmpty) {
        await newUserDoc.update({
          "mutualFriends": FieldValue.arrayUnion([user.id])
        });
      }
    }
  }

  // 👤 Register new user
  Future<void> registeruser() async {
    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      final User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fname': fname.text,
          'lname': lname.text,
          'email': user.email,
          'photoUrl': 'https://i.pravatar.cc/150?u=${user.uid}', // optional avatar
          'mutualFriends': [],
        });

        await generateFriendSuggestions(user.uid);

        Fluttertoast.showToast(msg: "Account created successfully");

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Mainpage()));
      }
    } catch (e, stacktrace) {
      print("Registration error: $e");
      print("StackTrace: $stacktrace");
      Fluttertoast.showToast(msg: "Failed to register: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_ios, size: 24),
              const SizedBox(height: 30),
              const Text(
                "Create your Facebook account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fname,
                      decoration: InputDecoration(
                        hintText: "First Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: lname,
                      decoration: InputDecoration(
                        hintText: "Last Name",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: registeruser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.blueAccent.shade700,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => loginPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Already have an account",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
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

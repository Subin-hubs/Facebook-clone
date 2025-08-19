import 'package:facebok/Security/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Pages/HOME/Home_page.dart';
import 'Pages/MENU/ProfilePage.dart';
import 'Pages/MENU/morepage.dart';
import 'Pages/FRIENDS/friendpage.dart';
import 'Pages/mainpage.dart';
import 'Security/backgroundIamge.dart';
import 'Security/forgetpassword.dart';
import 'Security/photo.dart';
import 'Security/signupPage.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: loginPage(),
    );
  }
}

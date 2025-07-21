import 'package:facebok/Security/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Pages/Home_page.dart';
import 'Pages/postfunction.dart';
import 'chatspage.dart';
import 'Pages/create_post.dart';
import 'Pages/friendpage.dart';
import 'Pages/mainpage.dart' hide HomePageContent;
import 'Security/1sign.dart';
import 'Security/forgetpassword.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: home_pages(),
    );
  }
}

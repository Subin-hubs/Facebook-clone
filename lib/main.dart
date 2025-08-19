import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'Pages/NOTIFICATATION/notificatationpage.dart';
import 'Security/login_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Background message: ${message.notification?.title}");

  // Save notification to Firestore
  await FirebaseFirestore.instance.collection("notifications").add({
    "title": message.notification?.title ?? "No title",
    "body": message.notification?.body ?? "No body",
    "timestamp": FieldValue.serverTimestamp(),
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic("allUsers");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 Foreground message: ${message.notification?.title}");
      await FirebaseFirestore.instance.collection("notifications").add({
        "title": message.notification?.title ?? "No title",
        "body": message.notification?.body ?? "No body",
        "timestamp": FieldValue.serverTimestamp(),
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("📩 Opened from notification: ${message.notification?.title}");
      await FirebaseFirestore.instance.collection("notifications").add({
        "title": message.notification?.title ?? "No title",
        "body": message.notification?.body ?? "No body",
        "timestamp": FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: loginPage(),
      routes: {
        "/notifications": (_) => const NotificationPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';

class friends extends StatefulWidget {
  const friends({super.key});

  @override
  State<friends> createState() => _friendsState();
}

class _friendsState extends State<friends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friends"),
      ),
    );
  }
}

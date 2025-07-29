import 'package:flutter/material.dart';

class notificatation extends StatefulWidget {
  const notificatation({super.key});

  @override
  State<notificatation> createState() => _notificatationState();
}

class _notificatationState extends State<notificatation> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notification"),
        ],
      ),
    ));
  }
}

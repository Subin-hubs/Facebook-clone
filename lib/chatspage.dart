import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chats extends StatefulWidget {
  const chats({super.key});

  @override
  State<chats> createState() => _chatsState();
}

class _chatsState extends State<chats> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("messenger",style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20
                ),),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 170),
                child: Image(image: AssetImage("assests/messangericon.png"),height: 40,width: 40,),
              )
            ],
          )
        ],
      )
    ));
  }
}

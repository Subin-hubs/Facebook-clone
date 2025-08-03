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
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.arrow_back_ios),
            Text("messenger"),
            Icon(Icons.add)
          ],
        ),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SearchBar(
              hintText: "Ask meta AI or search",
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5,right: 5),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assests/defaultimg.png'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Subin",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/defaultimg.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Subin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/defaultimg.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Subin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/defaultimg.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Subin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/defaultimg.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Subin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assests/defaultimg.png'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Subin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],),
    ));
  }
}

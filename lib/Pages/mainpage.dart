import 'dart:developer';

import 'package:facebok/Pages/HOME/Home_page.dart';
import 'package:flutter/material.dart';
import 'REELS/Reels.dart';
import 'FRIENDS/friendpage.dart';
import 'MARKET/marketplacepage.dart';
import 'MENU/morepage.dart';
import 'NOTIFICATATION/notificatationpage.dart';

class Mainpage extends StatefulWidget {
  int currentIndex;
  bool navigation;
   Mainpage(this.currentIndex,this.navigation);

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _currentIndex = 0;
  bool navigation = false;
  late PageController _pageController = PageController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
      _currentIndex= widget.currentIndex;
      navigation = widget.navigation;
   if(navigation==true)
     _pageController = PageController(
      initialPage: widget.currentIndex,
    );
  }
  final List<Widget> pages = const [
    HomePages(),
    reels(),
    friends(),
    marketplace(),
    notificatation(),
    more(),
  ];

   _onTabTapped(int index) {
    log(index.toString());
    setState(() {
    _currentIndex = index;
    navigation==true?
        index = widget.currentIndex:null;
    });
 _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  setState(() {
    navigation = false;
  });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blueAccent.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.slow_motion_video_outlined), label: "Reels"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Marketplace"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

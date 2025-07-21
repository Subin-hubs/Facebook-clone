import 'package:facebok/Security/login_page.dart';
import 'package:facebok/Security/signupPage.dart';
import 'package:flutter/material.dart';

class BeforeSignUp extends StatefulWidget {
  const BeforeSignUp({super.key});

  @override
  State<BeforeSignUp> createState() => _BeforeSignUpState();
}

class _BeforeSignUpState extends State<BeforeSignUp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(

      body:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column (crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Icon(Icons.arrow_back_ios),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text("Join facebook",style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold
            ),),
          ),
          Image(image: AssetImage("assests/startSignup.jpg")),
          Text("Create an account to connect with friends, family and communicates of people who share your interests",style: TextStyle(
            fontSize: 14,
          ),),
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Container(width:MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupPage()));

          },style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.shade700,

          ), child: Text("Get Started",style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),))),
        ),
            Padding(
              padding: const EdgeInsets.only(top:10),
              child: Container(width:MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>loginPage()));

              },style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,

              ), child: Text("I already have an account",style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),))),
            ),
        ],),
      ),
    ));
  }
}

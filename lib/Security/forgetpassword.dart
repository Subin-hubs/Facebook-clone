import 'package:facebok/Security/login_page.dart';
import 'package:flutter/material.dart';

class forgetPassword extends StatefulWidget {
  const forgetPassword({super.key});

  @override
  State<forgetPassword> createState() => _forgetPasswordState();
}

class _forgetPasswordState extends State<forgetPassword> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 12, left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: GestureDetector(onTap:(){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>loginPage()));
              },
                  child: Icon(Icons.arrow_back_ios)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("Find your account",style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            Text("Enter your mobile number.",style: TextStyle(
              fontSize: 13,

            ),),
            TextFormField(decoration: InputDecoration(
              hintText: "Mobile number",
              filled: true,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(color: Colors.white))
            ),),
            Text("You may received WhatsApp and SMS notification from us for security and login purposes.",style: TextStyle(
              fontSize: 10,
            ),),
            Container(width: MediaQuery.of(context).size.width,
              child: ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
              ), child: Text("Continue",style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(width: MediaQuery.of(context).size.width,child: ElevatedButton(onPressed: (){},style:
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ), child: Text("Search by email instead",style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),))),
            ),
          ],
        ),
      ),
    ));
  }
}

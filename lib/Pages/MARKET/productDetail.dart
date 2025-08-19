import 'dart:convert';

import 'package:flutter/material.dart';

class productDetail extends StatefulWidget {
  final String name;
  final String price;
  final String description;
  final String image;

  const productDetail({
    Key? key,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  }) : super(key: key);


  @override
  State<productDetail> createState() => _productDetailState();
}

class _productDetailState extends State<productDetail> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Product"),
      ),
      body:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Image.memory(base64Decode(widget.image),height: 300, width: 500,),
        
            Padding(
              padding:  EdgeInsets.only(left: 15,right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.name,style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Rs ${widget.price}",style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
                  ),
        
        
                  SizedBox(height: 20,),
                  // Time
                  Text("Listed about an hour ago-Flutter",style: TextStyle(fontSize: 12,color: Colors.grey),),
                  //Add function
        
        
        
                  SizedBox(height: 50,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Image.asset("assests/alerts.png",height: 25,width: 25,),
                          Text("Alerts",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset("assests/messanger.png",height: 25,width: 25,),
                          Text("Message",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset("assests/darkShare.png",height: 20,width: 25,),
                          Text("Share",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)
                        ],
                      ),
        
                      Column(
                        children: [
                          Image.asset("assests/darkLove.png",height: 20,width: 25,),
                          Text("Save",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)
                        ],
                      ),
        
        
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20,),
        
                    Row(
                      children: [
                        Text("Description ",style: TextStyle(fontWeight: FontWeight.bold),),
        
                      ],
                    ),
        
                  Text(widget.description, style: TextStyle(fontSize: 12),),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
        
        
          ],
        ),
      ),
    ));
  }
}

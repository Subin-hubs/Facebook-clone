import 'dart:convert';
import 'package:flutter/material.dart';

class Storyview extends StatefulWidget {
  final String fname;
  final String lname;
  final String ppimage; // profile picture in base64
  final String storyImage; // story image in base64
  final String name;
  final String image;

  const Storyview({
    Key? key,
    required this.fname,
    required this.lname,
    required this.ppimage,
    required this.storyImage,
    required this.name,
    required this.image,
  }) : super(key: key);

  @override
  State<Storyview> createState() => _StoryviewState();
}

class _StoryviewState extends State<Storyview> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Fullscreen story image - with error handling
            Positioned.fill(
              child: widget.storyImage.isNotEmpty
                  ? Image.memory(
                base64Decode(widget.storyImage),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading story image: $error');
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Failed to load story',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 50,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No story content',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top bar with profile image + name
            Positioned(
              top: 16,
              left: 16,
              right: 60, // Make room for close button
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: widget.ppimage.isNotEmpty
                          ? Image.memory(
                        base64Decode(widget.ppimage),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading profile image: $error');
                          return Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.name.isNotEmpty ? widget.name : "${widget.fname} ${widget.lname}".trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
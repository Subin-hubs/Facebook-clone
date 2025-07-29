import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StoryWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String profileUrl;

  const StoryWidget({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileUrl,
  });

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  final picker = ImagePicker();

  Future<void> _uploadStory() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance.ref().child(
        'stories/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = await ref.putFile(file);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('stories')
        .add({
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> _fetchStories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('stories')
        .get();

    final now = Timestamp.now();
    final validStories = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final timestamp = doc['timestamp'] as Timestamp;
      final difference = now.toDate().difference(timestamp.toDate()).inHours;

      if (difference >= 24) {
        await doc.reference.delete(); // delete expired
      } else {
        validStories.add(doc.data());
      }
    }

    return validStories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchStories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
        }

        final stories = snapshot.data!;

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: _uploadStory,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      image: DecorationImage(
                        image: NetworkImage(widget.profileUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.blue),
                          ),
                        ),
                        const Positioned(
                          bottom: 8,
                          left: 8,
                          child: Text(
                            "Create Story",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final story = stories[index - 1];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(story['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

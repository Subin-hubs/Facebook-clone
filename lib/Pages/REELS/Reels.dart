import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final Future<List<Map<String, dynamic>>> reelsFuture = _getAllReels();

  static Future<List<Map<String, dynamic>>> _getAllReels() async {
    try {
      final query = await FirebaseFirestore.instance
          .collectionGroup('reels')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> reelsWithUser = [];

      for (var doc in query.docs) {
        final reelData = doc.data();
        final userId = reelData['userId'];

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final userData = userDoc.data() ?? {};

        reelsWithUser.add({
          'image': reelData['image'] ?? '',
          'text': reelData['text'] ?? '',
          'timestamp': reelData['timestamp'],
          'userProfile': userData['ppimage'] ?? '',
          'userName':
          "${userData['fname'] ?? ''} ${userData['lname'] ?? ''}".trim(),
        });
      }

      return reelsWithUser;
    } catch (e) {
      debugPrint("Error fetching reels: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: reelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading reels",
                  style: TextStyle(color: Colors.black)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No reels yet",
                  style: TextStyle(color: Colors.black)),
            );
          }

          final reels = snapshot.data!;

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];

              return Stack(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        const Center(
                          child: Text(
                            'Reels',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: _buildSafeImage(reel['image']),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage:
                                _safeProfileImage(reel['userProfile']),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reel['userName'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reel['text'] != null &&
                            reel['text'].toString().isNotEmpty)
                          Padding(
                            padding:
                            const EdgeInsets.only(right: 200, bottom: 10),
                            child: Text(
                              reel['text'],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.right,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 🔘 Action buttons on right side
                  Positioned(
                    right: 12,
                    bottom: 100,
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up_alt_outlined,
                              color: Colors.black),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.black),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.black),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSafeImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return const Text('No image', style: TextStyle(color: Colors.black));
    }

    try {
      final cleaned = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;

      final bytes = base64Decode(cleaned);
      return Image.memory(bytes);
    } catch (e) {
      debugPrint('Image decode error: $e');
      return const Text('Invalid image', style: TextStyle(color: Colors.red));
    }
  }

  ImageProvider _safeProfileImage(String imageData) {
    try {
      final cleaned = imageData.contains(',')
          ? imageData.split(',').last
          : imageData;

      final bytes = base64Decode(cleaned);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint('Profile image decode error: $e');
      return const AssetImage('assets/default_avatar.png');
    }
  }
}
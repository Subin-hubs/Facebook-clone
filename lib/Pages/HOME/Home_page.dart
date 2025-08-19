import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebok/Pages/HOME/story.dart';
import 'package:facebok/Pages/HOME/create_reels.dart';
import 'package:facebok/Pages/HOME/widgets/story.dart';
import 'package:facebok/Pages/mainpage.dart';
import 'package:facebok/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../chat/userChatsPage.dart' hide Chatpage;
import 'StoryViewerPage.dart';
import 'Storyviewpage.dart';
import 'create_post.dart';
import 'dart:developer';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  final TextEditingController _commentController = TextEditingController();
  String _currentPostUID = '';
  String _currentPostOwnerUID = '';

  Future<void> sendComment({
    required String userUID,
    required String postUID,
    required String commentText,
  }) async {
    if (commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    final userData = userDoc.data();
    if (userData == null) return;

    final base64Image = userData['ppimage'] ?? '';
    final userName = userData['fname'] ?? 'Anonymous';

    final commentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userUID)
        .collection('posts')
        .doc(postUID)
        .collection('comments')
        .doc(); // Auto-ID

    await commentRef.set({
      'commentText': commentText.trim(),
      'userName': userName,
      'userImageBase64': base64Image,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void showBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.post_add, color: Colors.blue),
                title: Text("Create Post"),
                onTap: () {
                  Navigator.pop(context); // close sheet
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePost()));// open another bottom sheet
                },

              ),

              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.video_collection, color: Colors.red),
                title: Text("Create Reels"),
                onTap: () {
                  Navigator.pop(context); // close sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateReels()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showBottomSheetComment(String postUID, String postOwnerUID) {
    setState(() {
      _currentPostUID = postUID;
      _currentPostOwnerUID = postOwnerUID;
      _commentController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75, // 75% screen height
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(postOwnerUID)
                          .collection('posts')
                          .doc(postUID)
                          .collection('comments')
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No comments yet.\nBe the first to comment!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final comments = snapshot.data!.docs;

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index].data() as Map<String, dynamic>;
                            final commentText = comment['commentText'] ?? '';
                            final userName = comment['userName'] ?? 'Anonymous';
                            final userImageBase64 = comment['userImageBase64'] ?? '';
                            final timestamp = comment['timestamp'] as Timestamp?;

                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Image
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: userImageBase64.isNotEmpty
                                        ? MemoryImage(base64Decode(userImageBase64))
                                        : AssetImage('assests/defaultimg.png') as ImageProvider,
                                  ),
                                  SizedBox(width: 12),

                                  // Comment Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                commentText,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (timestamp != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4, left: 12),
                                            child: Text(
                                              formatTimestamp(timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Comment Input
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: [
                        // Current User Profile Image
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                          builder: (context, snapshot) {
                            String profileImage = '';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final userData = snapshot.data!.data() as Map<String, dynamic>;
                              profileImage = userData['ppimage'] ?? '';
                            }

                            return CircleAvatar(
                              radius: 18,
                              backgroundImage: profileImage.isNotEmpty
                                  ? MemoryImage(base64Decode(profileImage))
                                  : AssetImage('assests/defaultimg.png') as ImageProvider,
                            );
                          },
                        ),
                        SizedBox(width: 12),

                        // Text Input
                        Expanded(
                          child: TextFormField(
                            controller: _commentController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Write a comment...",
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        // Send Button
                        GestureDetector(
                          onTap: () async {
                            if (_commentController.text.trim().isNotEmpty) {
                              await sendComment(
                                userUID: _currentPostOwnerUID,
                                postUID: _currentPostUID,
                                commentText: _commentController.text,
                              );
                              _commentController.clear();
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 22,
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> Like(String postId, int currentLikeCount, bool liked,
      List likedByUserId, String postsUserId) async {
    try {
      final user = _auth.currentUser;
      final postsRef = _firestore
          .collection('users')
          .doc(postsUserId)
          .collection('posts')
          .doc(postId);
      List finalLikedByUsersId = [];

      if (likedByUserId.isEmpty) {
        finalLikedByUsersId.add(user!.uid);
      } else {
        for (int i = 0; i < likedByUserId.length; i++) {
          finalLikedByUsersId.add(likedByUserId[i]);
          if (liked == true) {
            finalLikedByUsersId.remove(user!.uid);
          } else {
            finalLikedByUsersId.add(user!.uid);
          }
        }
      }
      await postsRef.update({
        'likes': liked == true ? currentLikeCount - 1 : currentLikeCount + 1,
        'likedBy': finalLikedByUsersId
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> fetchLikes(String userId, String postID) async {
    DocumentSnapshot postDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postID)
        .get();

    if (postDoc.exists) {
      final data = postDoc.data() as Map<String, dynamic>;
      return data['likes'] ?? 0;
    }

    return 0;
  }

  Future<int> fetchCommentCount(String postOwnerUID, String postUID) async {
    try {
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(postOwnerUID)
          .collection('posts')
          .doc(postUID)
          .collection('comments')
          .get();

      return commentsSnapshot.docs.length;
    } catch (e) {
      print('Error fetching comment count: $e');
      return 0;
    }
  }

  // Updated Stories Widget - Handles multiple stories per user
  Widget _buildStoriesSection() {
    return Container(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<Widget> storyItems = [];

          // Add "Create Story" as first item
          storyItems.add(_buildCreateStoryItem());

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final stories = snapshot.data!.docs;

            // Group stories by userId to show only the latest story per user
            Map<String, QueryDocumentSnapshot> latestStoriesByUser = {};

            for (var storyDoc in stories) {
              final storyData = storyDoc.data() as Map<String, dynamic>;
              final userId = storyData['userId'] ?? '';

              if (userId.isNotEmpty) {
                // If this is the first story for this user OR this story is newer
                if (!latestStoriesByUser.containsKey(userId)) {
                  latestStoriesByUser[userId] = storyDoc;
                }
                // Since stories are ordered by timestamp desc, first occurrence is the latest
              }
            }

            // Convert to story items
            latestStoriesByUser.forEach((userId, storyDoc) {
              final storyData = storyDoc.data() as Map<String, dynamic>;
              storyItems.add(_buildStoryItem(storyDoc.id, storyData, userId));
            });
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: storyItems.length,
            itemBuilder: (context, index) => storyItems[index],
          );
        },
      ),
    );
  }

  Widget _buildCreateStoryItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CreateStory()),
        );
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            String profileImage = '';
            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              profileImage = userData['ppimage'] ?? '';
            }

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            child: profileImage.isNotEmpty
                                ? Image.memory(
                              base64Decode(profileImage),
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey[400],
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'story',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoryItem(String storyId, Map<String, dynamic> storyData, String userId) {
    final userName = storyData['name'] ?? '';
    final profileUrl = storyData['profileUrl'] ?? '';
    final storyImage = storyData['storyImage'] ?? '';

    return GestureDetector(
      onTap: () {
        if (storyImage.isNotEmpty) {
          // Navigate to story viewer that shows all stories from this user
          _navigateToUserStories(userId, userName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Story image not available')),
          );
        }
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: storyImage.isNotEmpty
                      ? Image.memory(
                    base64Decode(storyImage),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[400],
                        child: Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[400],
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: profileUrl.isNotEmpty
                      ? MemoryImage(base64Decode(profileUrl))
                      : AssetImage('assests/defaultimg.png') as ImageProvider,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Story count indicator - FIXED
            Positioned(
              top: 8,
              right: 8,
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('stories')
                    .where('userId', isEqualTo: userId)
                    .get(), // Removed orderBy to avoid index requirement
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${snapshot.data!.docs.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED Navigate to user stories (shows all stories from this user)
  void _navigateToUserStories(String userId, String userName) async {
    try {
      // Fetch all stories from this user (without orderBy to avoid index requirement)
      final storiesQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .get();

      if (storiesQuery.docs.isNotEmpty) {
        // Sort the stories by timestamp in code
        final stories = storiesQuery.docs;
        stories.sort((a, b) {
          final aTimestamp = a.data()['timestamp'] as Timestamp?;
          final bTimestamp = b.data()['timestamp'] as Timestamp?;

          if (aTimestamp == null || bTimestamp == null) return 0;
          return aTimestamp.compareTo(bTimestamp); // Ascending order (oldest first)
        });

        // Use the StoryViewerPage for multiple stories
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewerPage(
              stories: stories,
              initialIndex: 0,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No stories found')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "facebook",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.blueAccent.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showBottomSheetMenu();
                    },
                    child: Image.asset("assests/add.png",
                        height: 40, width: 40),
                  ),
                  SizedBox(width: 10),
                  Image.asset("assests/copy.png", height: 25, width: 25),
                  SizedBox(width: 10),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MessengerChatListPage()), // Use the new chat list page
                        );
                      },
                      child: Image.asset("assests/messanger.png", height: 20, width: 25)
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.white,
        body: CustomScrollView(
          slivers: [
            // "What's on your mind?" section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: const [
                          CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "What's on your mind?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        !snapshot.data!.exists) {
                      return const Text("Error loading user data");
                    }

                    final userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                    final ppImage = userData['ppimage'];

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: ppImage != null &&
                              ppImage.toString().isNotEmpty
                              ? MemoryImage(base64Decode(ppImage))
                              : const AssetImage("assests/defaultimg.png")
                          as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CreatePost()));
                            },
                            child: const Text(
                              "What's on your mind?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.image_outlined,
                              color: Colors.grey),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CreatePost()));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Stories section - Updated for multiple stories
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildStoriesSection(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: Divider(thickness: 4),
            ),

            // Posts feed
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                      child: Center(child: Text("Error: ${snapshot.error}")));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text("No posts available")));
                }

                final posts = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = posts[index];
                      List likedByUsersId = [];

                      if (post['likedBy'].length != 0) {
                        for (int i = 0; i < post['likedBy'].length; i++) {
                          if (!likedByUsersId.contains(post['likedBy'][i])) {
                            likedByUsersId.add(post['likedBy'][i]);
                          }
                        }
                      }

                      bool liked =
                      likedByUsersId.contains(_auth.currentUser!.uid);
                      log(liked.toString());
                      final text = post['text'] ?? '';
                      final image = post['image'];
                      final timestamp = post['timestamp'] as Timestamp?;
                      final userId = post['userId'];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchUserData(userId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (userSnapshot.hasError) {
                            return const Center(
                                child: Text("Error fetching user data"));
                          }

                          final userData = userSnapshot.data ?? {};
                          final userName =
                          "${userData['fname'] ?? ''} ${userData['lname'] ?? ''}"
                              .trim();
                          final profilePic = userData['ppimage'] ?? '';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: profilePic.isNotEmpty
                                            ? MemoryImage(
                                            base64Decode(profilePic))
                                            : const AssetImage(
                                            'assests/defaultimg.png')
                                        as ImageProvider,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (timestamp != null)
                                            Text(
                                              formatTimestamp(timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Text(
                                    text,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),

                                  if (image != null &&
                                      image.toString().isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(image),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),

                                  const SizedBox(height: 12),

                                  // Like count
                                  Text(
                                    "${post['likes']} ${post['likes'] == 1 ? 'like' : 'likes'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Divider(color: Colors.grey[300]),

                                  // Action buttons
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Like(
                                              post.id,
                                              post['likes'],
                                              liked,
                                              likedByUsersId,
                                              post['userId']);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              liked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_alt_outlined,
                                              color: liked
                                                  ? Colors.blueAccent
                                                  : Colors.grey[600],
                                              size: 20,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Like",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: liked
                                                    ? Colors.blueAccent
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          showBottomSheetComment(post.id, post['userId']);
                                        },
                                        child: Row(
                                          children: [
                                            Image.asset('assests/comment.png',width: 20,height: 20,),
                                            SizedBox(width: 6),
                                            Text(
                                              "Comment",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            // Comment count
                                            FutureBuilder<int>(
                                              future: fetchCommentCount(post['userId'], post.id),
                                              builder: (context, commentSnapshot) {
                                                if (commentSnapshot.hasData && commentSnapshot.data! > 0) {
                                                  return Text(
                                                    '(${commentSnapshot.data})',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  );
                                                }
                                                return SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.share_outlined,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Share",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
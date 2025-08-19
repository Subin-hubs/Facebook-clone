import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? currentUserId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final String targetUserId = widget.userId ?? currentUserId!;
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .get();

      if (doc.exists) {
        setState(() {
          profileData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Just now';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return 'Just now';
    }
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ProfilePicture(
                  imageUrl: profileData!['ppimage'],
                  firstName: profileData!['fname'],
                  lastName: profileData!['lname'],
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profileData!['fname']} ${profileData!['lname']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (post['text'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post['text'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          if (post['imageUrl'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Image.memory(
                base64Decode(post['imageUrl'].toString().split(',').last),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPostAction(Icons.thumb_up_outlined, 'Like'),
                const SizedBox(width: 24),
                _buildPostAction(Icons.chat_bubble_outline, 'Comment'),
                const SizedBox(width: 24),
                _buildPostAction(Icons.share_outlined, 'Share'),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[200]),
        ],
      ),
    );
  }

  Widget _buildReelCard(Map<String, dynamic> reel) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ProfilePicture(
                  imageUrl: profileData!['ppimage'],
                  firstName: profileData!['fname'],
                  lastName: profileData!['lname'],
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${profileData!['fname']} ${profileData!['lname']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPostAction(Icons.thumb_up_outlined, 'Like'),
                const SizedBox(width: 24),
                _buildPostAction(Icons.chat_bubble_outline, 'Comment'),
                const SizedBox(width: 24),
                _buildPostAction(Icons.share_outlined, 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileData == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final bool isOwnProfile =
        widget.userId == null || widget.userId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {},
                ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          if (profileData!['backgroundImage'] != null)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(profileData!['backgroundImage']
                                        .toString()
                                        .split(',')
                                        .last),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.grey[400]!, Colors.grey[600]!],
                                ),
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.2),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.camera_alt, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Add cover photo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: profileData!['ppimage'] != null
                              ? Image.memory(
                            base64Decode(profileData!['ppimage']
                                .toString()
                                .split(',')
                                .last),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.purple[500]!
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${profileData!['fname'][0]}${profileData!['lname'][0]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                              : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[400]!,
                                  Colors.purple[500]!
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${profileData!['fname'][0]}${profileData!['lname'][0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 70),
                        const SizedBox(height: 16),
                        Text(
                          '${profileData!['fname']} ${profileData!['lname']}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profileData!['friendsCount'] ?? 0} friends',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                  label: const Text(
                                    'Add to story',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit,
                                      color: Colors.black, size: 18),
                                  label: const Text(
                                    'Edit profile',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_horiz,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _selectedTabIndex == 0
                                              ? Colors.blue[600]!
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Posts',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedTabIndex == 0
                                            ? Colors.blue[600]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _selectedTabIndex == 1
                                              ? Colors.blue[600]!
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Photos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedTabIndex == 1
                                            ? Colors.blue[600]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 2),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _selectedTabIndex == 2
                                              ? Colors.blue[600]!
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Reels',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedTabIndex == 2
                                            ? Colors.blue[600]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedTabIndex == 0) ...[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId ?? currentUserId!)
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text('Error loading posts'),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.white,
                      padding: const EdgeInsets.all(40),
                      child: _buildEmptyState(
                        'No posts yet',
                        'When you share posts, they\'ll appear here.',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post =
                      posts[index].data() as Map<String, dynamic>;
                      return _buildPostCard(post);
                    },
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ],
          if (_selectedTabIndex == 1) ...[
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                color: Colors.white,
                padding: const EdgeInsets.all(40),
                child: _buildEmptyState(
                  'No photos yet',
                  'When you share photos, they\'ll appear here.',
                ),
              ),
            ),
          ],
          if (_selectedTabIndex == 2) ...[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId ?? currentUserId!)
                  .collection('reels')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text('Error loading reels'),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final reels = snapshot.data?.docs ?? [];

                if (reels.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.white,
                      padding: const EdgeInsets.all(40),
                      child: _buildEmptyState(
                        'No reels yet',
                        'When you create reels, they\'ll appear here.',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final reel =
                      reels[index].data() as Map<String, dynamic>;
                      return _buildReelCard(reel);
                    },
                    childCount: reels.length,
                  ),
                );
              },
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final String firstName;
  final String lastName;
  final double size;
  final bool showCameraIcon;

  const ProfilePicture({
    Key? key,
    this.imageUrl,
    required this.firstName,
    required this.lastName,
    this.size = 120,
    this.showCameraIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.purple[500]!],
            ),
          ),
          child: imageUrl != null
              ? ClipOval(
            child: Image.memory(
              base64Decode(imageUrl!.toString().split(',').last),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildInitials();
              },
            ),
          )
              : _buildInitials(),
        ),
        if (showCameraIcon)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../MENU/ProfilePage.dart';
import 'ChatePage.dart';

class MessengerChatListPage extends StatefulWidget {
  const MessengerChatListPage({Key? key}) : super(key: key);

  @override
  State<MessengerChatListPage> createState() => _MessengerChatListPageState();
}

class _MessengerChatListPageState extends State<MessengerChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _updateUserOnlineStatus(true);
  }

  @override
  void dispose() {
    _updateUserOnlineStatus(false);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUserOnlineStatus(bool isOnline) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error updating online status: $e');
      }
    }
  }

  String formatLastMessageTime(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return DateFormat('h:mm a').format(messageTime);
    } else if (messageDate.isAfter(today.subtract(Duration(days: 7)))) {
      return DateFormat('EEE').format(messageTime); // Mon, Tue, etc.
    } else {
      return DateFormat('MMM d').format(messageTime); // Jan 1, etc.
    }
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return {};
  }

  // Create a consistent chat ID for two users
  String createChatId(String userId1, String userId2) {
    List<String> participants = [userId1, userId2];
    participants.sort();
    return participants.join('_');
  }

  Widget _buildStorySection() {
    return Container(
      height: 100,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<Widget> storyItems = [];

          // Add "Create story" as first item
          storyItems.add(_buildCreateStoryItem());

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final stories = snapshot.data!.docs;

            // Group stories by userId to show only the latest story per user
            Map<String, QueryDocumentSnapshot> latestStoriesByUser = {};

            for (var storyDoc in stories) {
              final storyData = storyDoc.data() as Map<String, dynamic>;
              final userId = storyData['userId'] ?? '';

              if (userId.isNotEmpty && !latestStoriesByUser.containsKey(userId)) {
                latestStoriesByUser[userId] = storyDoc;
              }
            }

            // Convert to story items
            latestStoriesByUser.forEach((userId, storyDoc) {
              final storyData = storyDoc.data() as Map<String, dynamic>;

              storyItems.add(
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(userId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Container(
                        width: 65,
                        margin: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                            ),
                            SizedBox(height: 4),
                            Container(
                              height: 10,
                              width: 40,
                              color: Colors.grey[300],
                            )
                          ],
                        ),
                      );
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final userName = userData['fname'] ?? 'Unknown';
                    final profileUrl = userData['ppimage'] ?? '';

                    return _buildStoryItemWithUser(
                      userName,
                      profileUrl,
                    );
                  },
                ),
              );
            });
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: storyItems.length,
            itemBuilder: (context, index) => storyItems[index],
          );
        },
      ),
    );
  }

  Widget _buildStoryItemWithUser(String userName, String profileUrl) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Story view coming soon!')),
          );
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: profileUrl.isNotEmpty
                      ? MemoryImage(base64Decode(profileUrl))
                      : AssetImage('assests/defaultimg.png') as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              userName.split(' ')[0], // First name only
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCreateStoryItem() {
    return Container(
      margin: EdgeInsets.only(right: 12),
      width: 65,
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to create story page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create story functionality coming soon!')),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.add, color: Colors.black, size: 24),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Create story',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(Map<String, dynamic> storyData, String userId) {
    // Use correct field names from your Firebase structure
    final userName = storyData['fname'] ?? 'Unknown';
    final profileUrl = storyData['ppimage'] ?? '';

    return Container(
      margin: EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to story view
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Story view coming soon!')),
          );
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: profileUrl.isNotEmpty
                      ? MemoryImage(base64Decode(profileUrl))
                      : AssetImage('assests/defaultimg.png') as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              userName.split(' ')[0], // First name only
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNewChat() async {
    // Show dialog to select user to chat with
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Start New Chat', style: TextStyle(color: Colors.black)),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(color: Colors.blue));
              }

              final users = snapshot.data!.docs.where((doc) {
                return doc.id != _auth.currentUser!.uid;
              }).toList();

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final userName = '${userData['fname'] ?? ''} ${userData['lname'] ?? ''}'.trim();
                  final profilePic = userData['ppimage'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? MemoryImage(base64Decode(profilePic))
                          : AssetImage('assests/defaultimg.png') as ImageProvider,
                    ),
                    title: Text(userName.isNotEmpty ? userName : 'Unknown User',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverUserID: users[index].id,
                            receiverUserName: userName,
                            receiverName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text('Please log in to view chats',
                style: TextStyle(color: Colors.black))
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Messenger',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: _startNewChat,
          ),
          Stack(
            children: [
              IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Text('f', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                onPressed: () {
                  // TODO: Implement profile menu
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Ask Meta AI or Search',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                  child: Icon(Icons.circle, color: Colors.white, size: 16),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
            ),
          ),

          // Stories section
          if (_searchQuery.isEmpty) _buildStorySection(),

          // Chat list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('participants', arrayContains: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.blue));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message, color: Colors.grey[600], size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No chats yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a new conversation',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _startNewChat,
                          child: Text('Start New Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final chats = snapshot.data!.docs;

                // Sort chats by lastMessageTime in code
                chats.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['lastMessageTime'] as Timestamp?;
                  final bTime = bData['lastMessageTime'] as Timestamp?;

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.compareTo(aTime);
                });

                // Filter chats based on search query
                List<QueryDocumentSnapshot> filteredChats = chats;
                if (_searchQuery.isNotEmpty) {
                  filteredChats = chats.where((chat) {
                    final chatData = chat.data() as Map<String, dynamic>;
                    final lastMessage = chatData['lastMessage']?.toString().toLowerCase() ?? '';
                    return lastMessage.contains(_searchQuery);
                  }).toList();
                }

                if (filteredChats.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No chats found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chatData = filteredChats[index].data() as Map<String, dynamic>;
                    final participants = List<String>.from(chatData['participants'] ?? []);
                    final lastMessage = chatData['lastMessage'] ?? '';
                    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
                    final lastMessageSender = chatData['lastMessageSender'] ?? '';

                    // Get the other participant (not current user)
                    final otherParticipantId = participants.firstWhere(
                          (id) => id != currentUser.uid,
                      orElse: () => '',
                    );

                    if (otherParticipantId.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(otherParticipantId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            title: Text(
                              'Loading...',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'Please wait...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }

                        final userData = userSnapshot.data!;
                        final userName = '${userData['fname'] ?? ''} ${userData['lname'] ?? ''}'.trim();
                        final profilePic = userData['ppimage'] ?? '';
                        final isOnline = userData['isOnline'] ?? false;

                        // Count unread messages
                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .doc(createChatId(currentUser.uid, otherParticipantId))
                              .collection('messages')
                              .where('receiverId', isEqualTo: currentUser.uid)
                              .where('isRead', isEqualTo: false)
                              .snapshots(),
                          builder: (context, unreadSnapshot) {
                            int unreadCount = unreadSnapshot.hasData ? unreadSnapshot.data!.docs.length : 0;

                            return ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: profilePic.isNotEmpty
                                        ? MemoryImage(base64Decode(profilePic))
                                        : AssetImage('assests/defaultimg.png') as ImageProvider,
                                  ),
                                  if (isOnline)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                userName.isNotEmpty ? userName : 'Unknown User',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  if (lastMessageSender == currentUser.uid)
                                    Text(
                                      'You: ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
                                      style: TextStyle(
                                        color: unreadCount > 0 ? Colors.black : Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (lastMessageTime != null) ...[
                                    Text(' • ', style: TextStyle(color: Colors.grey[600])),
                                    Text(
                                      formatLastMessageTime(lastMessageTime),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: unreadCount > 0
                                  ? Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      receiverUserID: otherParticipantId,
                                      receiverUserName: userName,
                                      receiverName: userName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
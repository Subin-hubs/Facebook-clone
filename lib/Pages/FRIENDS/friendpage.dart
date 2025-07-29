import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class friends extends StatefulWidget {
  const friends({super.key});

  @override
  State<friends> createState() => _friendsState();
}

class _friendsState extends State<friends> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection("users").get();
      final fetched = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['fname'] ?? '', // ✅ corrected key
          'imageUrl': data['imageUrl'] ?? '',
          'isFriend': data['isFriend'] ?? false,
          'mutuals': List<String>.from(data['mutuals'] ?? []),
        };
      }).toList();

      setState(() {
        users = fetched;
      });
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
  }

  Future<void> addFriend(String uid) async {
    await _firestore.collection("users").doc(uid).update({'isFriend': true});
    fetchUsers();
  }

  Future<void> removeFriend(String uid) async {
    await _firestore.collection("users").doc(uid).update({'isFriend': false});
    fetchUsers();
  }

  Widget buildMutualAvatars(List<String> mutuals) {
    final displayed = mutuals.take(3).toList();
    return Stack(
      children: displayed.asMap().entries.map((entry) {
        return Positioned(
          left: entry.key * 20.0,
          child: CircleAvatar(
            radius: 11,
            backgroundImage: NetworkImage(entry.value),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text("Friend Requests", style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: users.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final mutuals = user['mutuals'] as List<String>;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user['imageUrl'].isNotEmpty
                              ? NetworkImage(user['imageUrl'])
                              : null,
                          child: user['imageUrl'].isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              if (mutuals.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 22,
                                        child: buildMutualAvatars(mutuals),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${mutuals.length} mutual friends",
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => addFriend(user['uid']),
                            child: const Text("Add Friend"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => removeFriend(user['uid']),
                            child: const Text("Remove"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
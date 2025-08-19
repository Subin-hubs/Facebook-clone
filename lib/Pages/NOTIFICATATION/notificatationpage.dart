import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("timestamp", descending: true)
            .snapshots(includeMetadataChanges: true), // ensure real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Safe timestamp handling
              String timeString = "";
              if (data["timestamp"] != null && data["timestamp"] is Timestamp) {
                timeString =
                (data["timestamp"] as Timestamp).toDate().toLocal().toString().split(".")[0];
              }

              return ListTile(
                leading: const Icon(Icons.notifications, color: Colors.blue),
                title: Text(data["title"] ?? "No Title"),
                subtitle: Text(data["body"] ?? "No Body"),
                trailing: Text(
                  timeString,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

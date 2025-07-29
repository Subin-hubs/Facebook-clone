import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:facebok/Pages/MARKET/seller.dart';

class marketplace extends StatefulWidget {
  const marketplace({super.key});

  @override
  State<marketplace> createState() => _marketplaceState();
}

class _marketplaceState extends State<marketplace> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔝 Top Bar
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Marketplace",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Row(
                    children: const [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Icon(Icons.search),
                    ],
                  ),
                ],
              ),
            ),

            // 📦 Sell / For You Tabs
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Market_Sell()),
                      );
                    },
                    child: const Text(
                      "Sell",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Text("For you",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🛍️ Marketplace Grid
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('marketplace')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No products posted yet."));
                  }

                  final products = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data = products[index].data() as Map<String, dynamic>;
                      final base64Image = data['image'];
                      final bytes = base64Image != null && base64Image != ''
                          ? base64Decode(base64Image)
                          : null;

                      return GestureDetector(
                        onTap: () {
                          // 🔜 Add detailed view if needed
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🖼 Image
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                ),
                                child: bytes != null
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child:
                                  Image.memory(bytes, fit: BoxFit.cover),
                                )
                                    : const Center(
                                  child: Icon(Icons.image,
                                      size: 40, color: Colors.grey),
                                ),
                              ),

                              // 📝 Details
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'No name', // ✅ use lowercase 'name'
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹ ${data['price'] ?? 'N/A'}", // ✅ lowercase 'price'
                                      style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? '', // ✅ lowercase 'description'
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

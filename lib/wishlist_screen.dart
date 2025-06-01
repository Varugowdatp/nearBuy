import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your wishlist.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist 💖'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('wishlist')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your wishlist is empty 😕"));
          }

          final wishlistItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: wishlistItems.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final product = wishlistItems[index];
              final List images = product['images'];
              final image = images.isNotEmpty ? base64Decode(images[0]) : null;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading:
                      image != null
                          ? Image.memory(image, width: 60, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported, size: 60),
                  title: Text(product['name']),
                  subtitle: Text("₹${product['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('wishlist')
                          .doc(product.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Removed from Wishlist")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

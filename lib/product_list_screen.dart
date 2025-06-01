import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/product_detail.dart';

import 'order_confirmation_screen.dart';

class ProductListScreen extends StatelessWidget {
  final String shopId;

  const ProductListScreen({Key? key, required this.shopId}) : super(key: key);

  // 🔁 Add to Cart
  Future<void> addToCart(DocumentSnapshot product, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add to cart.")),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    await cartRef.doc(product.id).set(product.data() as Map<String, dynamic>);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to Cart!")));
  }

  // 💖 Add to Wishlist
  Future<void> addToWishlist(
    DocumentSnapshot product,
    BuildContext context,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add to wishlist.")),
      );
      return;
    }

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    final doc = await wishlistRef.doc(product.id).get();
    if (doc.exists) {
      await wishlistRef.doc(product.id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from Wishlist 💔")));
    } else {
      await wishlistRef
          .doc(product.id)
          .set(product.data() as Map<String, dynamic>);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to Wishlist 💖")));
    }
  }

  // ✅ Check if in Wishlist
  Future<bool> isInWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .doc(productId)
            .get();

    return doc.exists;
  }

  // 🛒 Order Now
  Future<void> orderNow(DocumentSnapshot product, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to place an order.")),
      );
      return;
    }

    final orderData = {
      'userId': user.uid,
      'productId': product.id,
      'shopId': product['shopId'],
      'name': product['name'],
      'price': product['price'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Products 🛍️'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .where('shopId', isEqualTo: shopId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products found for this shop 😕"),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final List images = product['images'];
              final image = images.isNotEmpty ? base64Decode(images[0]) : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔺 Product Image with Heart Icon
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child:
                                image != null
                                    ? Image.memory(
                                      image,
                                      width:
                                          MediaQuery.of(context).size.width +
                                          0.5,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 80),
                                    ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: FutureBuilder<bool>(
                              future: isInWishlist(product.id),
                              builder: (context, snapshot) {
                                final isWishlisted = snapshot.data ?? false;

                                return InkWell(
                                  onTap: () async {
                                    await addToWishlist(product, context);
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product['description'],
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹${product['price']}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => addToCart(product, context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellowAccent,
                                    ),
                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.black,
                                    ),
                                    label: const Text(
                                      "Add to Cart",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => orderNow(product, context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    icon: const Icon(
                                      Icons.flash_on,
                                      color: Colors.black,
                                    ),
                                    label: const Text(
                                      "Order Now",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

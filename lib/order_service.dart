// order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static Future<void> placeOrder({
    required Map<String, dynamic> productData,
    required String productId,
    required String paymentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderData = {
      'userId': user.uid,
      'productId': productId,
      'shopId': productData['shopId'],
      'name': productData['name'],
      'price': productData['price'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Pending',
      'paymentId': paymentId,
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminOrdersService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get active orders stream (real-time) - Normal orders only
  // Using single where clause to avoid composite index requirement
  // Filtering isGroupOrder in memory
  // Note: Firestore queries are case-sensitive
  // OrderModel uses lowercase enum names ('active', 'completed'), but some old orders might use capitalized
  // We'll query for lowercase (since that's what OrderModel.toFirestore() uses) and filter in memory
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActiveOrdersStream() {
    // Query by status only, filter isGroupOrder in memory
    // This avoids needing a composite index immediately
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get completed orders stream (real-time) - Normal orders only
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedOrdersStream() {
    // Query by status only, filter isGroupOrder in memory
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get active group orders stream (real-time)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActiveGroupOrdersStream() {
    // Query by status only, filter isGroupOrder in memory
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get completed group orders stream (real-time)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedGroupOrdersStream() {
    // Query by status only, filter isGroupOrder in memory
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all orders stream (for filtering)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update order status to completed
  static Future<bool> markOrderAsCompleted(String orderId) async {
    try {
      debugPrint('Attempting to mark order as completed: $orderId');
      
      // Try to update using orderId as document ID
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'orderStatus': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Order $orderId marked as completed successfully');
        return true;
      } on FirebaseException catch (e) {
        if (e.code == 'not-found') {
          debugPrint('Order document $orderId not found as document ID');
          // Order might use a different ID structure - this should be rare
          // But keep the error handling in case
          return false;
        } else {
          debugPrint('Error marking order as completed: ${e.code} - ${e.message}');
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error marking order as completed: $e');
      return false;
    }
  }

  // Update order status (generic)
  static Future<bool> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final validStatuses = ['active', 'completed', 'cancelled'];
      if (!validStatuses.contains(status)) {
        throw Exception('Invalid order status: $status');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Order $orderId status updated to $status');
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Get user name by ID
  static Future<String> getUserName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return 'Unknown User';
    }
  }

  // Get user names in batch
  static Future<Map<String, String>> getUserNames(List<String> userIds) async {
    final Map<String, String> userNames = {};
    
    try {
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshots = await Future.wait(
          batch.map((userId) => _firestore.collection('users').doc(userId).get()),
        );

        for (int j = 0; j < batch.length; j++) {
          final doc = snapshots[j];
          if (doc.exists) {
            final data = doc.data();
            userNames[batch[j]] = data?['name'] ?? 'Unknown User';
          } else {
            userNames[batch[j]] = 'Unknown User';
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting user names: $e');
    }

    return userNames;
  }
}


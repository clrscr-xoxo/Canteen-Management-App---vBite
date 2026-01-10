import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminDashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get today's date range (start and end of day)
  static Map<String, DateTime> _getTodayRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return {'start': startOfDay, 'end': endOfDay};
  }

  // Get total orders created today
  static Future<int> getTotalOrdersToday() async {
    try {
      final range = _getTodayRange();
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range['start']!))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range['end']!))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting total orders today: $e');
      return 0;
    }
  }

  // Get active orders count
  static Future<int> getActiveOrdersCount() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('orderStatus', isEqualTo: 'active')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting active orders count: $e');
      return 0;
    }
  }

  // Get revenue for today (only paid orders)
  // This is used for initial load; real-time updates are handled by the stream
  static Future<double> getRevenueToday() async {
    try {
      final range = _getTodayRange();
      // Query today's orders, then filter paid orders in memory (handles case variations)
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range['start']!))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range['end']!))
          .get();

      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Check if payment status is 'paid' (case-insensitive)
        final paymentStatus = data['paymentStatus']?.toString().toLowerCase() ?? '';
        if (paymentStatus == 'paid') {
          final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          totalRevenue += totalAmount;
          debugPrint('Revenue calculation: Adding ₹$totalAmount from order ${doc.id}');
        }
      }

      debugPrint('Total Revenue Today (initial load): ₹$totalRevenue');
      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting revenue today: $e');
      return 0.0;
    }
  }

  // Get popular items (top 5 most ordered items today)
  static Future<List<Map<String, dynamic>>> getPopularItems() async {
    try {
      final range = _getTodayRange();
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range['start']!))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range['end']!))
          .get();

      // Count occurrences of each item
      final Map<String, Map<String, dynamic>> itemCounts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];

        for (var item in items) {
          final itemData = item as Map<String, dynamic>;
          final itemId = itemData['itemId'] ?? itemData['id'] ?? '';
          final itemName = itemData['name'] ?? 'Unknown Item';
          final quantity = (itemData['quantity'] as num?)?.toInt() ?? 1;

          if (itemId.isNotEmpty) {
            if (itemCounts.containsKey(itemId)) {
              itemCounts[itemId]!['count'] = 
                  (itemCounts[itemId]!['count'] as int) + quantity;
            } else {
              itemCounts[itemId] = {
                'id': itemId,
                'name': itemName,
                'count': quantity,
              };
            }
          }
        }
      }

      // Sort by count and get top 5
      final sortedItems = itemCounts.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sortedItems.take(5).toList();
    } catch (e) {
      debugPrint('Error getting popular items: $e');
      return [];
    }
  }

  // Get recent orders (last 10 orders)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getRecentOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  // Get orders stream for real-time updates
  static Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get today's orders stream (real-time updates)
  // This stream is used to calculate revenue today as orders come in
  static Stream<QuerySnapshot<Map<String, dynamic>>> getTodayOrdersStream() {
    final range = _getTodayRange();
    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range['start']!))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range['end']!))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get today's paid orders stream (specifically for revenue calculation)
  // This filters paid orders created today for real-time revenue tracking
  static Stream<QuerySnapshot<Map<String, dynamic>>> getTodayPaidOrdersStream() {
    final range = _getTodayRange();
    // Note: Firestore doesn't support multiple 'where' clauses on different fields
    // with 'orderBy', so we'll filter paymentStatus in memory
    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(range['start']!))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(range['end']!))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get active orders stream
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActiveOrdersStream() {
    return _firestore
        .collection('orders')
        .where('orderStatus', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  // Get all user names in batch (more efficient)
  static Future<Map<String, String>> getUserNames(List<String> userIds) async {
    final Map<String, String> userNames = {};
    
    try {
      // Firestore 'in' query supports up to 10 items
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


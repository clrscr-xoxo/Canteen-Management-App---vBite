import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Debug service to check orders in Firestore
class AdminOrdersDebugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all orders (no filtering) - for debugging
  static Future<List<Map<String, dynamic>>> getAllOrdersDebug() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .limit(20)
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      debugPrint('=== DEBUG: Found ${orders.length} orders ===');
      for (var order in orders) {
        debugPrint('Order ID: ${order['id']}');
        debugPrint('  - orderStatus: ${order['orderStatus']}');
        debugPrint('  - isGroupOrder: ${order['isGroupOrder']}');
        debugPrint('  - userId: ${order['userId']}');
        debugPrint('  - totalAmount: ${order['totalAmount']}');
        debugPrint('  - createdAt: ${order['createdAt']}');
        debugPrint('---');
      }

      return orders;
    } catch (e) {
      debugPrint('Error getting all orders: $e');
      return [];
    }
  }

  // Count orders by type
  static Future<Map<String, int>> countOrdersByType() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      
      int total = snapshot.docs.length;
      int withIsGroupOrder = 0;
      int withoutIsGroupOrder = 0;
      int normalOrders = 0;
      int groupOrders = 0;
      
      final statusCounts = <String, int>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderStatus = data['orderStatus']?.toString() ?? 'unknown';
        final isGroupOrder = data['isGroupOrder'];
        
        statusCounts[orderStatus] = (statusCounts[orderStatus] ?? 0) + 1;
        
        if (isGroupOrder == null) {
          withoutIsGroupOrder++;
        } else {
          withIsGroupOrder++;
          if (isGroupOrder == true) {
            groupOrders++;
          } else {
            normalOrders++;
          }
        }
      }
      
      final result = {
        'total': total,
        'with_isGroupOrder_field': withIsGroupOrder,
        'without_isGroupOrder_field': withoutIsGroupOrder,
        'normal_orders': normalOrders,
        'group_orders': groupOrders,
        ...statusCounts,
      };
      
      debugPrint('=== ORDER STATISTICS ===');
      debugPrint(result.toString());
      
      return result;
    } catch (e) {
      debugPrint('Error counting orders: $e');
      return {};
    }
  }
}










import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum ReportTimeRange {
  today,
  week,
  month,
  year,
  custom,
}

class AdminReportsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get date range for a given time period
  static Map<String, DateTime> getDateRange(ReportTimeRange range, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    
    switch (range) {
      case ReportTimeRange.today:
        return {
          'start': DateTime(now.year, now.month, now.day, 0, 0, 0),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case ReportTimeRange.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return {
          'start': DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case ReportTimeRange.month:
        return {
          'start': DateTime(now.year, now.month, 1, 0, 0, 0),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case ReportTimeRange.year:
        return {
          'start': DateTime(now.year, 1, 1, 0, 0, 0),
          'end': DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
      case ReportTimeRange.custom:
        return {
          'start': customStart ?? DateTime(now.year, now.month, now.day, 0, 0, 0),
          'end': customEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59),
        };
    }
  }

  // Get revenue data for a time period
  static Future<Map<String, dynamic>> getRevenueData(ReportTimeRange range, {DateTime? customStart, DateTime? customEnd}) async {
    try {
      final dateRange = getDateRange(range, customStart: customStart, customEnd: customEnd);
      final start = dateRange['start']!;
      final end = dateRange['end']!;

      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return _processRevenueData(snapshot, start, end);
    } catch (e) {
      debugPrint('Error getting revenue data: $e');
      return {
        'totalRevenue': 0.0,
        'paidRevenue': 0.0,
        'pendingRevenue': 0.0,
        'totalOrders': 0,
        'paidOrders': 0,
        'pendingOrders': 0,
        'avgOrderValue': 0.0,
        'dailyRevenue': <String, double>{},
      };
    }
  }

  // Process revenue data from snapshot
  static Map<String, dynamic> _processRevenueData(QuerySnapshot<Map<String, dynamic>> snapshot, DateTime start, DateTime end) {
    double totalRevenue = 0.0;
    double paidRevenue = 0.0;
    double pendingRevenue = 0.0;
    int totalOrders = snapshot.docs.length;
    int paidOrders = 0;
    int pendingOrders = 0;

    // Daily revenue breakdown for charts
    final Map<String, double> dailyRevenue = {};
    
    // Initialize all days in range
    DateTime current = DateTime(start.year, start.month, start.day);
    while (current.isBefore(end) || current.isAtSameMomentAs(DateTime(end.year, end.month, end.day))) {
      final dayKey = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      dailyRevenue[dayKey] = 0.0;
      current = current.add(const Duration(days: 1));
    }

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final paymentStatus = (data['paymentStatus']?.toString().toLowerCase() ?? 'pending').trim();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      
      final dayKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      
      if (paymentStatus == 'paid') {
        paidRevenue += totalAmount;
        paidOrders++;
        dailyRevenue[dayKey] = (dailyRevenue[dayKey] ?? 0.0) + totalAmount;
      } else {
        pendingRevenue += totalAmount;
        pendingOrders++;
      }
      
      totalRevenue += totalAmount;
    }

    // Calculate average order value
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return {
      'totalRevenue': totalRevenue,
      'paidRevenue': paidRevenue,
      'pendingRevenue': pendingRevenue,
      'totalOrders': totalOrders,
      'paidOrders': paidOrders,
      'pendingOrders': pendingOrders,
      'avgOrderValue': avgOrderValue,
      'dailyRevenue': dailyRevenue,
    };
  }

  // Get top selling items by quantity and revenue
  static Future<List<Map<String, dynamic>>> getTopSellingItems(
    ReportTimeRange range, {
    DateTime? customStart,
    DateTime? customEnd,
    int limit = 10,
  }) async {
    try {
      final dateRange = getDateRange(range, customStart: customStart, customEnd: customEnd);
      final start = dateRange['start']!;
      final end = dateRange['end']!;

      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      // Count occurrences and revenue for each item
      final Map<String, Map<String, dynamic>> itemData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        final paymentStatus = (data['paymentStatus']?.toString().toLowerCase() ?? '').trim();
        final isPaid = paymentStatus == 'paid';

        for (var item in items) {
          final itemInfo = item as Map<String, dynamic>;
          final itemId = itemInfo['itemId'] ?? itemInfo['id'] ?? '';
          final itemName = itemInfo['name'] ?? 'Unknown Item';
          final quantity = (itemInfo['quantity'] as num?)?.toInt() ?? 1;
          final price = (itemInfo['price'] as num?)?.toDouble() ?? 0.0;
          final totalItemPrice = price * quantity;

          if (itemId.isNotEmpty) {
            if (itemData.containsKey(itemId)) {
              itemData[itemId]!['quantity'] = (itemData[itemId]!['quantity'] as int) + quantity;
              itemData[itemId]!['orders'] = (itemData[itemId]!['orders'] as int) + 1;
              if (isPaid) {
                itemData[itemId]!['revenue'] = (itemData[itemId]!['revenue'] as double) + totalItemPrice;
              }
            } else {
              itemData[itemId] = {
                'id': itemId,
                'name': itemName,
                'quantity': quantity,
                'revenue': isPaid ? totalItemPrice : 0.0,
                'orders': 1,
                'price': price,
              };
            }
          }
        }
      }

      // Sort by quantity (top sellers)
      final sortedByQuantity = itemData.values.toList()
        ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

      return sortedByQuantity.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting top selling items: $e');
      return [];
    }
  }

  // Get order statistics by status
  static Future<Map<String, dynamic>> getOrderStatistics(
    ReportTimeRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    try {
      final dateRange = getDateRange(range, customStart: customStart, customEnd: customEnd);
      final start = dateRange['start']!;
      final end = dateRange['end']!;

      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      int activeOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int groupOrders = 0;
      int individualOrders = 0;

      // Processing time data
      final List<double> processingTimes = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderStatus = (data['orderStatus']?.toString().toLowerCase() ?? '').trim();
        final isGroupOrder = data['isGroupOrder'] == true || data['isGroupOrder'] == 'true';
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        // Count by status
        if (orderStatus == 'active') {
          activeOrders++;
        } else if (orderStatus == 'completed') {
          completedOrders++;
          // Calculate processing time
          if (createdAt != null && updatedAt != null) {
            final duration = updatedAt.difference(createdAt).inMinutes;
            processingTimes.add(duration.toDouble());
          }
        } else if (orderStatus == 'cancelled') {
          cancelledOrders++;
        }

        // Count by type
        if (isGroupOrder) {
          groupOrders++;
        } else {
          individualOrders++;
        }
      }

      // Calculate average processing time
      double avgProcessingTime = 0.0;
      if (processingTimes.isNotEmpty) {
        avgProcessingTime = processingTimes.reduce((a, b) => a + b) / processingTimes.length;
      }

      final totalOrders = snapshot.docs.length;
      final completionRate = totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;

      return {
        'totalOrders': totalOrders,
        'activeOrders': activeOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'groupOrders': groupOrders,
        'individualOrders': individualOrders,
        'completionRate': completionRate,
        'avgProcessingTime': avgProcessingTime,
      };
    } catch (e) {
      debugPrint('Error getting order statistics: $e');
      return {
        'totalOrders': 0,
        'activeOrders': 0,
        'completedOrders': 0,
        'cancelledOrders': 0,
        'groupOrders': 0,
        'individualOrders': 0,
        'completionRate': 0.0,
        'avgProcessingTime': 0.0,
      };
    }
  }

  // Get peak hours analysis
  static Future<Map<String, dynamic>> getPeakHoursAnalysis(
    ReportTimeRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    try {
      final dateRange = getDateRange(range, customStart: customStart, customEnd: customEnd);
      final start = dateRange['start']!;
      final end = dateRange['end']!;

      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      // Hourly breakdown (0-23)
      final Map<int, Map<String, dynamic>> hourlyData = {};
      
      // Initialize all hours
      for (int i = 0; i < 24; i++) {
        hourlyData[i] = {
          'hour': i,
          'orderCount': 0,
          'revenue': 0.0,
        };
      }

      // Day of week breakdown (0 = Monday, 6 = Sunday)
      final Map<int, Map<String, dynamic>> dayOfWeekData = {};
      for (int i = 0; i < 7; i++) {
        dayOfWeekData[i] = {
          'day': i,
          'orderCount': 0,
          'revenue': 0.0,
        };
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final paymentStatus = (data['paymentStatus']?.toString().toLowerCase() ?? '').trim();
        final isPaid = paymentStatus == 'paid';

        final hour = createdAt.hour;
        final dayOfWeek = createdAt.weekday - 1; // Convert to 0-6 (Monday-Sunday)

        hourlyData[hour]!['orderCount'] = (hourlyData[hour]!['orderCount'] as int) + 1;
        if (isPaid) {
          hourlyData[hour]!['revenue'] = (hourlyData[hour]!['revenue'] as double) + totalAmount;
        }

        dayOfWeekData[dayOfWeek]!['orderCount'] = (dayOfWeekData[dayOfWeek]!['orderCount'] as int) + 1;
        if (isPaid) {
          dayOfWeekData[dayOfWeek]!['revenue'] = (dayOfWeekData[dayOfWeek]!['revenue'] as double) + totalAmount;
        }
      }

      // Find peak hour
      int peakHour = 0;
      int maxOrders = 0;
      for (var entry in hourlyData.entries) {
        if (entry.value['orderCount'] as int > maxOrders) {
          maxOrders = entry.value['orderCount'] as int;
          peakHour = entry.key;
        }
      }

      // Find peak day
      int peakDay = 0;
      int maxDayOrders = 0;
      for (var entry in dayOfWeekData.entries) {
        if (entry.value['orderCount'] as int > maxDayOrders) {
          maxDayOrders = entry.value['orderCount'] as int;
          peakDay = entry.key;
        }
      }

      return {
        'hourlyData': hourlyData.values.toList(),
        'dayOfWeekData': dayOfWeekData.values.toList(),
        'peakHour': peakHour,
        'peakDay': peakDay,
      };
    } catch (e) {
      debugPrint('Error getting peak hours analysis: $e');
      return {
        'hourlyData': <Map<String, dynamic>>[],
        'dayOfWeekData': <Map<String, dynamic>>[],
        'peakHour': 0,
        'peakDay': 0,
      };
    }
  }
}


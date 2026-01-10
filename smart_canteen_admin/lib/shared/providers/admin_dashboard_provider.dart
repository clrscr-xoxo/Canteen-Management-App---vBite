import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/admin_dashboard_service.dart';

class AdminDashboardProvider with ChangeNotifier {
  // Statistics
  int _totalOrdersToday = 0;
  int _activeOrdersCount = 0;
  double _revenueToday = 0.0;
  List<Map<String, dynamic>> _popularItems = [];
  
  // Recent orders
  List<Map<String, dynamic>> _recentOrders = [];
  Map<String, String> _userNames = {}; // Cache for user names
  
  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingRecentOrders = false;
  
  // Error states
  String? _errorMessage;

  // Getters
  int get totalOrdersToday => _totalOrdersToday;
  int get activeOrdersCount => _activeOrdersCount;
  double get revenueToday => _revenueToday;
  List<Map<String, dynamic>> get popularItems => _popularItems;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingRecentOrders => _isLoadingRecentOrders;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Initialize dashboard data
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadStatistics(),
      loadRecentOrders(),
    ]);
  }

  // Load all statistics
  Future<void> loadStatistics() async {
    _isLoadingStats = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        AdminDashboardService.getTotalOrdersToday(),
        AdminDashboardService.getActiveOrdersCount(),
        AdminDashboardService.getRevenueToday(),
        AdminDashboardService.getPopularItems(),
      ]);

      _totalOrdersToday = results[0] as int;
      _activeOrdersCount = results[1] as int;
      _revenueToday = results[2] as double;
      _popularItems = results[3] as List<Map<String, dynamic>>;

      _isLoadingStats = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingStats = false;
      _errorMessage = 'Failed to load statistics: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load recent orders
  Future<void> loadRecentOrders() async {
    _isLoadingRecentOrders = true;
    notifyListeners();

    try {
      final snapshot = await AdminDashboardService.getRecentOrdersStream().first;
      _recentOrders = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      // Load user names for all orders
      final userIds = _recentOrders
          .map((order) => order['userId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (userIds.isNotEmpty) {
        _userNames = await AdminDashboardService.getUserNames(userIds);
      }

      _isLoadingRecentOrders = false;
      notifyListeners();
    } catch (e) {
      _isLoadingRecentOrders = false;
      _errorMessage = 'Failed to load recent orders: ${e.toString()}';
      notifyListeners();
    }
  }

  // Setup real-time listeners
  void setupRealtimeListeners() {
    // Listen to today's orders for stats updates (including revenue calculation)
    // This stream provides real-time updates as orders are created/updated
    AdminDashboardService.getTodayOrdersStream().listen((snapshot) {
      _updateStatsFromSnapshot(snapshot);
    });

    // Listen to recent orders
    AdminDashboardService.getRecentOrdersStream().listen((snapshot) {
      _updateRecentOrders(snapshot);
    });
  }

  // Update stats from snapshot (called in real-time as orders are added/updated)
  // This calculates revenue today by summing up all paid orders created today
  void _updateStatsFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    // Get today's date for filtering (to ensure we only count today's orders)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    int totalOrders = 0;
    double revenue = 0.0;
    final Map<String, Map<String, dynamic>> itemCounts = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      // Verify the order was created today (double-check in case of timezone issues)
      final createdAt = data['createdAt'];
      DateTime? orderDate;
      
      if (createdAt is Timestamp) {
        orderDate = createdAt.toDate();
      } else if (createdAt is DateTime) {
        orderDate = createdAt;
      }
      
      // Only process orders created today
      if (orderDate != null && 
          orderDate.isAfter(startOfDay.subtract(const Duration(days: 1))) && 
          orderDate.isBefore(endOfDay.add(const Duration(days: 1)))) {
        
        totalOrders++;
        
        // Calculate revenue: only add if order is paid
        // Handle case variations: 'paid', 'Paid', 'PAID'
        final paymentStatus = data['paymentStatus']?.toString().toLowerCase() ?? '';
        if (paymentStatus == 'paid') {
          final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          revenue += totalAmount;
          debugPrint('Added to revenue: ₹$totalAmount (Order: ${doc.id})');
        }

        // Count items for popular items (only from today's orders)
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
    }

    _totalOrdersToday = totalOrders;
    _revenueToday = revenue;

    debugPrint('Revenue Today Updated: ₹$_revenueToday (from $totalOrders orders)');

    // Update popular items
    final sortedItems = itemCounts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    _popularItems = sortedItems.take(5).toList();

    // Update active orders count
    _updateActiveOrdersCount();

    notifyListeners();
  }

  // Update active orders count
  Future<void> _updateActiveOrdersCount() async {
    try {
      _activeOrdersCount = await AdminDashboardService.getActiveOrdersCount();
    } catch (e) {
      debugPrint('Error updating active orders count: $e');
    }
  }

  // Update recent orders from snapshot
  void _updateRecentOrders(QuerySnapshot<Map<String, dynamic>> snapshot) async {
    _recentOrders = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();

    // Load user names for new orders
    final userIds = _recentOrders
        .map((order) => order['userId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (userIds.isNotEmpty) {
      _userNames = await AdminDashboardService.getUserNames(userIds);
    }

    notifyListeners();
  }

  // Get user name from cache
  String getUserName(String userId) {
    return _userNames[userId] ?? 'Unknown User';
  }

  // Get user names map (for widgets)
  Map<String, String> get userNames => _userNames;

  // Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


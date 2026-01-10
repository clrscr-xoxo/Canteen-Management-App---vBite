import 'package:flutter/foundation.dart';
import '../../core/services/admin_orders_service.dart';

class AdminOrdersProvider with ChangeNotifier {
  // Active orders
  List<Map<String, dynamic>> _activeOrders = [];
  
  // Completed orders
  List<Map<String, dynamic>> _completedOrders = [];
  
  // User names cache
  final Map<String, String> _userNames = {};
  
  // Loading states
  final bool _isLoadingActive = false;
  final bool _isLoadingCompleted = false;
  String? _processingOrderId; // Track which order is being processed
  
  // Error states
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get activeOrders => _activeOrders;
  List<Map<String, dynamic>> get completedOrders => _completedOrders;
  Map<String, String> get userNames => _userNames;
  bool get isLoadingActive => _isLoadingActive;
  bool get isLoadingCompleted => _isLoadingCompleted;
  bool get isProcessing => _processingOrderId != null;
  String? get processingOrderId => _processingOrderId;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Setup real-time listeners
  void setupListeners() {
    debugPrint('Setting up order listeners...');
    
    // Use getAllOrdersStream and filter in memory to handle case variations
    // This ensures we catch all orders regardless of status casing
    AdminOrdersService.getAllOrdersStream().listen(
      (snapshot) {
        debugPrint('All orders stream updated: ${snapshot.docs.length} total documents');
        
        // Split into active and completed based on status
        final allOrders = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        
        // Update active orders
        _updateActiveOrdersFromList(allOrders);
        
        // Update completed orders
        _updateCompletedOrdersFromList(allOrders);
      },
      onError: (error) {
        debugPrint('Error loading orders: $error');
        _errorMessage = 'Error loading orders: $error';
        notifyListeners();
      },
    );
  }
  
  // Update active orders from a list (filtering in memory)
  void _updateActiveOrdersFromList(List<Map<String, dynamic>> allOrders) {
    _activeOrders = allOrders.where((order) {
      final rawStatus = order['orderStatus']?.toString() ?? '';
      final orderStatus = rawStatus.toLowerCase().trim();
      final isGroupOrder = order['isGroupOrder'] == true || order['isGroupOrder'] == 'true';
      
      final isActive = orderStatus == 'active';
      final isNotGroupOrder = !isGroupOrder;
      final willShow = isActive && isNotGroupOrder;
      
      return willShow;
    }).toList();
    
    debugPrint('Active orders: ${_activeOrders.length} after filtering');
    _loadUserNames(_activeOrders);
    notifyListeners();
  }
  
  // Update completed orders from a list (filtering in memory)
  void _updateCompletedOrdersFromList(List<Map<String, dynamic>> allOrders) {
    _completedOrders = allOrders.where((order) {
      final rawStatus = order['orderStatus']?.toString() ?? '';
      final orderStatus = rawStatus.toLowerCase().trim();
      final isGroupOrder = order['isGroupOrder'] == true || order['isGroupOrder'] == 'true';
      
      final isCompleted = orderStatus == 'completed';
      final isNotGroupOrder = !isGroupOrder;
      final willShow = isCompleted && isNotGroupOrder;
      
      debugPrint('Completed order check: orderId=${order['id']}, status="$orderStatus" (raw: "$rawStatus"), isGroupOrder=$isGroupOrder, willShow=$willShow');
      
      return willShow;
    }).toList();
    
    debugPrint('Completed orders: ${_completedOrders.length} after filtering');
    _loadUserNames(_completedOrders);
    notifyListeners();
  }


  // Load user names for orders
  Future<void> _loadUserNames(List<Map<String, dynamic>> orders) async {
    final userIds = orders
        .map((order) => order['userId'] as String? ?? '')
        .where((id) => id.isNotEmpty && !_userNames.containsKey(id))
        .toSet()
        .toList();

    if (userIds.isNotEmpty) {
      final newUserNames = await AdminOrdersService.getUserNames(userIds);
      _userNames.addAll(newUserNames);
    }
  }

  // Mark order as completed
  Future<bool> markOrderAsCompleted(String orderId) async {
    _processingOrderId = orderId;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Provider: Marking order $orderId as completed');
      final success = await AdminOrdersService.markOrderAsCompleted(orderId);
      
      _processingOrderId = null;
      if (!success) {
        _errorMessage = 'Failed to mark order as completed';
        debugPrint('Provider: Failed to mark order $orderId as completed');
      } else {
        debugPrint('Provider: Order $orderId marked as completed successfully');
        // Don't remove from active orders list here - let the real-time stream handle it
        // This ensures the order automatically moves to completed tab via Firestore stream
      }
      notifyListeners();
      return success;
    } catch (e) {
      _processingOrderId = null;
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Provider: Error marking order as completed: $e');
      notifyListeners();
      return false;
    }
  }

  // Get user name from cache
  String getUserName(String userId) {
    return _userNames[userId] ?? 'Unknown User';
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh orders (re-setup listeners)
  void refresh() {
    setupListeners();
  }
}


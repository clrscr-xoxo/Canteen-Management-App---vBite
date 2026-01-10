import 'package:flutter/foundation.dart';
import '../../core/services/admin_orders_service.dart';

class AdminGroupOrdersProvider with ChangeNotifier {
  // Active group orders
  List<Map<String, dynamic>> _activeOrders = [];
  
  // Completed group orders
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
    debugPrint('Setting up group order listeners...');
    
    // Use getAllOrdersStream and filter in memory to handle case variations
    // This ensures we catch all orders regardless of status casing
    AdminOrdersService.getAllOrdersStream().listen(
      (snapshot) {
        debugPrint('All orders stream updated: ${snapshot.docs.length} total documents');
        
        // Split into active and completed group orders based on status
        final allOrders = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        
        // Update active group orders
        _updateActiveOrdersFromList(allOrders);
        
        // Update completed group orders
        _updateCompletedOrdersFromList(allOrders);
      },
      onError: (error) {
        debugPrint('Error loading group orders: $error');
        _errorMessage = 'Error loading group orders: $error';
        notifyListeners();
      },
    );
  }
  
  // Update active group orders from a list (filtering in memory)
  void _updateActiveOrdersFromList(List<Map<String, dynamic>> allOrders) {
    _activeOrders = allOrders.where((order) {
      final rawStatus = order['orderStatus']?.toString() ?? '';
      final orderStatus = rawStatus.toLowerCase().trim();
      final isGroupOrder = order['isGroupOrder'] == true || order['isGroupOrder'] == 'true';
      
      final isActive = orderStatus == 'active';
      final willShow = isActive && isGroupOrder;
      
      return willShow;
    }).toList();
    
    debugPrint('Active group orders: ${_activeOrders.length} after filtering');
    _loadUserNames(_activeOrders);
    notifyListeners();
  }
  
  // Update completed group orders from a list (filtering in memory)
  void _updateCompletedOrdersFromList(List<Map<String, dynamic>> allOrders) {
    _completedOrders = allOrders.where((order) {
      final rawStatus = order['orderStatus']?.toString() ?? '';
      final orderStatus = rawStatus.toLowerCase().trim();
      final isGroupOrder = order['isGroupOrder'] == true || order['isGroupOrder'] == 'true';
      
      final isCompleted = orderStatus == 'completed';
      final willShow = isCompleted && isGroupOrder;
      
      debugPrint('Completed group order check: orderId=${order['id']}, status="$orderStatus" (raw: "$rawStatus"), isGroupOrder=$isGroupOrder, willShow=$willShow');
      
      return willShow;
    }).toList();
    
    debugPrint('Completed group orders: ${_completedOrders.length} after filtering');
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
      final success = await AdminOrdersService.markOrderAsCompleted(orderId);
      
      _processingOrderId = null;
      if (!success) {
        _errorMessage = 'Failed to mark order as completed';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _processingOrderId = null;
      _errorMessage = 'Error: ${e.toString()}';
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


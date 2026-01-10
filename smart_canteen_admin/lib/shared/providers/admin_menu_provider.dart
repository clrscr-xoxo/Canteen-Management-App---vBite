import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/admin_menu_service.dart';

class AdminMenuProvider with ChangeNotifier {
  List<Map<String, dynamic>> _menuItems = [];
  List<Map<String, dynamic>> _categories = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _processingItemId; // Track which item is being processed
  
  // Filters
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool? _availabilityFilter; // null = all, true = available, false = sold out

  // Getters
  List<Map<String, dynamic>> get menuItems => _menuItems;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool? get availabilityFilter => _availabilityFilter;
  bool isProcessingItem(String itemId) => _processingItemId == itemId;

  // Get filtered menu items
  List<Map<String, dynamic>> get filteredMenuItems {
    var filtered = List<Map<String, dynamic>>.from(_menuItems);

    // Filter by category
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      filtered = filtered.where((item) {
        return item['categoryId'] == _selectedCategoryId;
      }).toList();
    }

    // Filter by availability
    if (_availabilityFilter != null) {
      filtered = filtered.where((item) {
        final isAvailable = item['isAvailable'] ?? true;
        return isAvailable == _availabilityFilter;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final description = (item['description'] ?? '').toString().toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Load menu items (one-time)
  Future<void> loadMenuItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _menuItems = await AdminMenuService.getMenuItems();
      
      _categories = await AdminMenuService.getCategories();
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load menu items: ${e.toString()}';
      notifyListeners();
    }
  }

  // Setup real-time listeners
  void setupListeners() {
    // Listen to menu items changes
    AdminMenuService.getMenuItemsStream().listen(
      (snapshot) {
        _menuItems = snapshot.docs.map((doc) {
          final data = doc.data();
          // Always use Firestore document ID for updates
          return {
            'firestoreDocId': doc.id, // Store Firestore document ID for updates
            ...data, // Include all data from document
            'id': doc.id, // Override 'id' with Firestore document ID (for consistency)
          };
        }).toList();
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading menu items: $error';
        notifyListeners();
      },
    );

    // Listen to categories changes
    AdminMenuService.getCategoriesStream().listen(
      (snapshot) {
        _categories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading categories: $error');
      },
    );
  }

  // Toggle item availability
  Future<bool> toggleItemAvailability(String itemId) async {
    final item = _menuItems.firstWhere(
      (item) => item['id'] == itemId || item['firestoreDocId'] == itemId,
      orElse: () => {},
    );

    if (item.isEmpty) {
      _errorMessage = 'Item not found';
      notifyListeners();
      return false;
    }

    final currentAvailability = item['isAvailable'] ?? true;
    final newAvailability = !currentAvailability;

    // Use Firestore document ID for the update (this is the actual document ID, not the 'id' field)
    // The item['firestoreDocId'] is the actual Firestore document ID we need
    final docIdToUse = item['firestoreDocId'] ?? item['id'] ?? itemId;
    
    debugPrint('Updating item: itemId=$itemId, docIdToUse=$docIdToUse, firestoreDocId=${item['firestoreDocId']}, id=${item['id']}');

    _processingItemId = itemId;
    notifyListeners();

    try {
      final success = await AdminMenuService.toggleItemAvailability(
        docIdToUse,
        newAvailability,
      );

      if (success) {
        // Update local state immediately for better UX
        final index = _menuItems.indexWhere((i) => i['id'] == itemId);
        if (index != -1) {
          _menuItems[index]['isAvailable'] = newAvailability;
          _menuItems[index]['updatedAt'] = FieldValue.serverTimestamp();
        }
      } else {
        _errorMessage = 'Failed to update item availability';
      }

      _processingItemId = null;
      notifyListeners();
      return success;
    } catch (e) {
      _processingItemId = null;
      _errorMessage = 'Error updating item: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Set filter by category
  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set availability filter
  void setAvailabilityFilter(bool? filter) {
    _availabilityFilter = filter;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _availabilityFilter = null;
    notifyListeners();
  }

  // Refresh menu items
  Future<void> refresh() async {
    await loadMenuItems();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


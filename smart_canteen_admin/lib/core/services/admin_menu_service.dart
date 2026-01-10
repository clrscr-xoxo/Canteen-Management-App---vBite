import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminMenuService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _menuItemsCollection = 'menuItems';

  // Get all menu items stream (real-time updates)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMenuItemsStream() {
    return _firestore
        .collection(_menuItemsCollection)
        .orderBy('name')
        .snapshots();
  }

  // Get all menu items (one-time fetch)
  static Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      final snapshot = await _firestore
          .collection(_menuItemsCollection)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Always use Firestore document ID for updates
        // Preserve any 'id' field from data, but use doc.id for document operations
        final result = {
          'firestoreDocId': doc.id, // Store Firestore document ID separately
          ...data, // Include all data from document
          'id': doc.id, // Override 'id' with Firestore document ID (for consistency)
        };
        return result;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching menu items: $e');
      return [];
    }
  }

  // Toggle item availability (Sold Out / Available)
  // itemId should be the Firestore document ID (not the 'id' field from document data)
  static Future<bool> toggleItemAvailability(String itemId, bool isAvailable) async {
    try {
      debugPrint('Attempting to update item: docId=$itemId, isAvailable=$isAvailable');
      
      // Try to update using itemId as document ID directly
      await _firestore
          .collection(_menuItemsCollection)
          .doc(itemId)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Item $itemId availability updated to: $isAvailable');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        debugPrint('Document $itemId not found as document ID, searching by id field...');
        
        // If document ID doesn't work, search by 'id' field in document data
        try {
          final querySnapshot = await _firestore
              .collection(_menuItemsCollection)
              .where('id', isEqualTo: itemId)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            debugPrint('Item with id field "$itemId" not found in Firestore');
            return false;
          }

          // Update using the actual Firestore document ID
          final docId = querySnapshot.docs.first.id;
          await _firestore
              .collection(_menuItemsCollection)
              .doc(docId)
              .update({
            'isAvailable': isAvailable,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          debugPrint('Item $itemId availability updated to: $isAvailable (found by id field, doc ID: $docId)');
          return true;
        } catch (searchError) {
          debugPrint('Error searching for item by id field: $searchError');
          return false;
        }
      } else {
        debugPrint('Error updating item availability: ${e.code} - ${e.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating item availability: $e');
      return false;
    }
  }

  // Set item as sold out
  static Future<bool> setItemSoldOut(String itemId) async {
    return await toggleItemAvailability(itemId, false);
  }

  // Set item as available
  static Future<bool> setItemAvailable(String itemId) async {
    return await toggleItemAvailability(itemId, true);
  }

  // Get categories stream
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .orderBy('sortOrder')
        .snapshots();
  }

  // Get categories (one-time fetch)
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('sortOrder')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }
}


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/admin_constants.dart';

class AdminAuthService {
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  AdminAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password (Admin only)
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (!email.toLowerCase().endsWith('@vit.edu.in')) {
        throw Exception('Only VIT email addresses (@vit.edu.in) are allowed');
      }

      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized. Please refresh the page.');
      }

      final UserCredential userCredential = 
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Sign-in failed. Please try again.');
      }

      // Verify user is admin
      final bool isAdmin = await _verifyAdminRole(user.uid);
      if (!isAdmin) {
        await _firebaseAuth.signOut();
        throw Exception(
          'Access denied. This account does not have admin privileges. '
          'Please contact your administrator if you believe this is an error.',
        );
      }

      // Update last login
      await _updateLastLogin(user.uid);

      return {
        'success': true,
        'userId': user.uid,
        'email': user.email,
        'name': user.displayName ?? user.email!.split('@').first,
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Verify user has admin role in Firestore
  Future<bool> _verifyAdminRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        debugPrint('User document not found in Firestore');
        return false;
      }

      final userData = userDoc.data();
      final role = userData?['role'] as String?;
      
      debugPrint('User role: $role');
      return role == AdminConstants.adminRole;
    } catch (e) {
      debugPrint('Error verifying admin role: $e');
      return false;
    }
  }

  // Get current user role
  Future<String?> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return userDoc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      return {
        'id': user.uid,
        'email': userData['email'] ?? user.email,
        'name': userData['name'] ?? user.displayName ?? user.email!.split('@').first,
        'role': userData['role'] ?? 'admin',
      };
    } catch (e) {
      debugPrint('Error getting current user data: $e');
      return null;
    }
  }

  // Update last login
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign-out failed: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get Firebase error message
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid. Please use a valid VIT email (@vit.edu.in).';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}


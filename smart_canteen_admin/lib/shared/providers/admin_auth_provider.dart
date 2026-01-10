import 'package:flutter/foundation.dart';
import '../../core/services/admin_auth_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;

  AdminAuthProvider() {
    _checkAuthState();
  }

  // Check authentication state
  void _checkAuthState() async {
    if (_authService.isAuthenticated) {
      // Verify user is still an admin
      final role = await _authService.getUserRole();
      if (role == 'admin') {
        _isAuthenticated = true;
        _currentUser = await _authService.getCurrentUserData();
      } else {
        // User is not admin anymore - sign them out
        _isAuthenticated = false;
        _currentUser = null;
        await _authService.signOut();
      }
    } else {
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(email, password);
      _currentUser = result;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    _currentUser = await _authService.getCurrentUserData();
    notifyListeners();
  }
}


// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  pendingApproval,
}

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;
  String _role = '';
  bool _isAdmin = false;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String get role => _role;
  bool get isAdmin => _isAdmin;
  
  UserProvider() {
    // Check if user is already signed in
    _checkCurrentUser();
  }
  
  Future<void> _checkCurrentUser() async {
    try {
      final user = _authService.currentUser;
      
      if (user != null) {
        // Check role and approval status
        final roleAndStatus = await _authService.getUserRoleAndStatus();
        final userModel = await _authService.getCurrentUserData();
        
        if (userModel != null) {
          _currentUser = userModel;
          _role = roleAndStatus['role'];
          _isAdmin = _role == 'admin';
          
          if (_role == 'volunteer' && !roleAndStatus['isApproved']) {
            _status = AuthStatus.pendingApproval;
          } else {
            _status = AuthStatus.authenticated;
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('Error in _checkCurrentUser: $e');
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password, {bool isAdmin = false}) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
        isAdmin: isAdmin,
      );
      
      await _checkCurrentUser();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String volunteerId,
    required String bloodGroup,
    required String place,
    required String department,
  }) async {
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        volunteerId: volunteerId,
        bloodGroup: bloodGroup,
        place: place,
        department: department,
      );
      
      await _checkCurrentUser();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      
      await _checkCurrentUser();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      
      _currentUser = null;
      _role = '';
      _isAdmin = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    await _checkCurrentUser();
  }
}
// lib/providers/volunteer_provider.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/services/user_service.dart';

class VolunteerProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _volunteers = [];
  List<UserModel> _pendingVolunteers = [];
  List<UserModel> _approvedVolunteers = [];
  List<UserModel> _admins = [];

  bool _isLoading = false;
  String _error = '';

  // Getters
  List<UserModel> get volunteers => _volunteers;
  List<UserModel> get pendingVolunteers => _pendingVolunteers;
  List<UserModel> get approvedVolunteers => _approvedVolunteers;
  List<UserModel> get admins => _admins;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize listeners
  void initListeners() {
    _isLoading = true;
    notifyListeners();

    // Listen for volunteers
    _userService.getVolunteers().listen(
      (volunteerList) {
        _volunteers = volunteerList;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );

    // Listen for pending volunteers
    _userService.getPendingVolunteers().listen(
      (pendingList) {
        _pendingVolunteers = pendingList;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );

    // Listen for approved volunteers
    _userService.getApprovedVolunteers().listen(
      (approvedList) {
        _approvedVolunteers = approvedList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );

    // Listen for admins
    _userService.getAdmins().listen(
      (adminList) {
        _admins = adminList;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Approve volunteer
  Future<void> approveVolunteer(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.approveVolunteer(userId);

      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reject volunteer
  Future<void> rejectVolunteer(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.rejectVolunteer(userId);

      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Make admin
  Future<void> makeAdmin(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.makeAdmin(userId);

      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Continuing from updateUserProfile method
  Future<void> updateUserProfile(
    String userId, {
    String? name,
    String? bloodGroup,
    String? place,
    String? department,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.updateUserProfile(
        userId,
        name: name,
        bloodGroup: bloodGroup,
        place: place,
        department: department,
      );

      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

}

// lib/providers/attendance_provider.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/attendance_model.dart';
import 'package:nssapp/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  
  List<AttendanceModel> _eventAttendance = [];
  List<AttendanceModel> _volunteerAttendance = [];
  double _attendancePercentage = 0.0;
  
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<AttendanceModel> get eventAttendance => _eventAttendance;
  List<AttendanceModel> get volunteerAttendance => _volunteerAttendance;
  double get attendancePercentage => _attendancePercentage;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Get attendance for an event
  void getEventAttendance(String eventId) {
    _isLoading = true;
    notifyListeners();
    
    _attendanceService.getEventAttendance(eventId).listen(
      (attendanceList) {
        _eventAttendance = attendanceList;
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }
  
  // Get attendance for a volunteer
  void getVolunteerAttendance(String volunteerId) {
    _isLoading = true;
    notifyListeners();
    
    _attendanceService.getVolunteerAttendance(volunteerId).listen(
      (attendanceList) {
        _volunteerAttendance = attendanceList;
        _isLoading = false;
        _error = '';
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
    
    // Also fetch attendance percentage
    _fetchAttendancePercentage(volunteerId);
  }
  
  // Calculate attendance percentage
  Future<void> _fetchAttendancePercentage(String volunteerId) async {
    try {
      final percentage = await _attendanceService.calculateAttendancePercentage(volunteerId);
      _attendancePercentage = percentage;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
  
  // Mark attendance
  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _attendanceService.markAttendance(attendance);
      
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
  
  // Batch mark attendance
  Future<void> batchMarkAttendance(
    String eventId,
    Map<String, bool> attendanceStatus,
    String markedBy,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _attendanceService.batchMarkAttendance(
        eventId,
        attendanceStatus,
        markedBy,
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
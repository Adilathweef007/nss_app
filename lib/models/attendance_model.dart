// lib/models/attendance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String eventId;
  final String volunteerId;
  final bool isPresent;
  final String markedBy;
  final DateTime markedAt;

  AttendanceModel({
    required this.id,
    required this.eventId,
    required this.volunteerId,
    required this.isPresent,
    required this.markedBy,
    required this.markedAt,
  });

  // Convert Firestore document to AttendanceModel
  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      eventId: map['eventId'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      isPresent: map['isPresent'] ?? false,
      markedBy: map['markedBy'] ?? '',
      markedAt: map['markedAt'] != null
          ? (map['markedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert AttendanceModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'volunteerId': volunteerId,
      'isPresent': isPresent,
      'markedBy': markedBy,
      'markedAt': markedAt,
    };
  }

  // Create a copy of AttendanceModel with modified attributes
  AttendanceModel copyWith({
    String? id,
    String? eventId,
    String? volunteerId,
    bool? isPresent,
    String? markedBy,
    DateTime? markedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      volunteerId: volunteerId ?? this.volunteerId,
      isPresent: isPresent ?? this.isPresent,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  // Mock data for UI development - can be removed when using Firestore
  static List<AttendanceModel> getMockAttendance() {
    return [
      AttendanceModel(
        id: '1',
        eventId: '3', // Clean Campus Initiative (past event)
        volunteerId: '1', // John Doe
        isPresent: true,
        markedBy: '5', // Dr. Rajesh Kumar
        markedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Add other mock attendance records as needed
    ];
  }

  // Method to get attendance for a specific volunteer
  static List<AttendanceModel> getVolunteerAttendance(String volunteerId) {
    return getMockAttendance().where((attendance) => attendance.volunteerId == volunteerId).toList();
  }

  // Method to get attendance for a specific event
  static List<AttendanceModel> getEventAttendance(String eventId) {
    return getMockAttendance().where((attendance) => attendance.eventId == eventId).toList();
  }

  // Method to calculate attendance percentage for a volunteer
  static double calculateAttendancePercentage(String volunteerId) {
    // This implementation will be replaced by Firestore queries
    return 75.0; // Placeholder value
  }
}
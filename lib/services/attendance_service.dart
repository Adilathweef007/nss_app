import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nssapp/models/attendance_model.dart';
import 'package:nssapp/services/firebase_service.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Mark attendance
  Future<void> markAttendance(AttendanceModel attendance) async {
    try {
      // Check if attendance already exists
      QuerySnapshot existingAttendance = await _firestore
          .collection('attendance')
          .where('eventId', isEqualTo: attendance.eventId)
          .where('volunteerId', isEqualTo: attendance.volunteerId)
          .get();
      
      if (existingAttendance.docs.isNotEmpty) {
        // Update existing attendance
        await _firestore.collection('attendance').doc(existingAttendance.docs.first.id).update({
          'isPresent': attendance.isPresent,
          'markedBy': attendance.markedBy,
          'markedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new attendance record
        await _firestore.collection('attendance').add({
          'eventId': attendance.eventId,
          'volunteerId': attendance.volunteerId,
          'isPresent': attendance.isPresent,
          'markedBy': attendance.markedBy,
          'markedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
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
      WriteBatch batch = _firestore.batch();
      
      for (var entry in attendanceStatus.entries) {
        String volunteerId = entry.key;
        bool isPresent = entry.value;
        
        // Check if attendance already exists
        QuerySnapshot existingAttendance = await _firestore
            .collection('attendance')
            .where('eventId', isEqualTo: eventId)
            .where('volunteerId', isEqualTo: volunteerId)
            .get();
        
        if (existingAttendance.docs.isNotEmpty) {
          // Update existing attendance
          batch.update(
            _firestore.collection('attendance').doc(existingAttendance.docs.first.id),
            {
              'isPresent': isPresent,
              'markedBy': markedBy,
              'markedAt': FieldValue.serverTimestamp(),
            },
          );
        } else {
          // Create new attendance record
          batch.set(
            _firestore.collection('attendance').doc(),
            {
              'eventId': eventId,
              'volunteerId': volunteerId,
              'isPresent': isPresent,
              'markedBy': markedBy,
              'markedAt': FieldValue.serverTimestamp(),
            },
          );
        }
      }
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get attendance for an event
  Stream<List<AttendanceModel>> getEventAttendance(String eventId) {
    return _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Get attendance for a volunteer
  Stream<List<AttendanceModel>> getVolunteerAttendance(String volunteerId) {
    return _firestore
        .collection('attendance')
        .where('volunteerId', isEqualTo: volunteerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Calculate attendance percentage
  Future<double> calculateAttendancePercentage(String volunteerId) async {
    try {
      // Get all events the volunteer was approved for
      QuerySnapshot approvedEventsSnapshot = await _firestore
          .collection('events')
          .where('approvedParticipants', arrayContains: volunteerId)
          .where('endDate', isLessThan: DateTime.now())  // Only past events
          .get();
      
      if (approvedEventsSnapshot.docs.isEmpty) return 0.0;
      
      int totalEvents = approvedEventsSnapshot.docs.length;
      
      // Get all attendance records where volunteer was present
      QuerySnapshot presentAttendance = await _firestore
          .collection('attendance')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('isPresent', isEqualTo: true)
          .get();
      
      int presentCount = presentAttendance.docs.length;
      
      return (presentCount / totalEvents) * 100;
    } catch (e) {
      return 0.0;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/services/firebase_service.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Create event
  Future<DocumentReference> createEvent(EventModel event) async {
    try {
      return await _firestore.collection('events').add({
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate,
        'endDate': event.endDate,
        'location': event.location,
        'maxParticipants': event.maxParticipants,
        'registeredParticipants': event.registeredParticipants,
        'approvedParticipants': event.approvedParticipants,
        'createdBy': event.createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'title': event.title,
        'description': event.description,
        'startDate': event.startDate,
        'endDate': event.endDate,
        'location': event.location,
        'maxParticipants': event.maxParticipants,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all events
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get upcoming events
  Stream<List<EventModel>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThan: DateTime.now())
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Register for event
  Future<void> registerForEvent(String eventId, String volunteerId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'registeredParticipants': FieldValue.arrayUnion([volunteerId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Approve participant
  Future<void> approveParticipant(String eventId, String volunteerId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'approvedParticipants': FieldValue.arrayUnion([volunteerId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Reject participant
  Future<void> rejectParticipant(String eventId, String volunteerId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'registeredParticipants': FieldValue.arrayRemove([volunteerId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get events for a specific volunteer
  Stream<List<EventModel>> getVolunteerEvents(String volunteerId) {
    return _firestore
        .collection('events')
        .where('registeredParticipants', arrayContains: volunteerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
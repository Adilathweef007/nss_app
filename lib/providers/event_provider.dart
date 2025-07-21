// lib/providers/event_provider.dart
import 'package:flutter/material.dart';
import 'package:nssapp/models/event_model.dart';
import 'package:nssapp/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  
  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _ongoingEvents = [];
  List<EventModel> _pastEvents = [];
  
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get ongoingEvents => _ongoingEvents;
  List<EventModel> get pastEvents => _pastEvents;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Initialize listeners
  void initListeners() {
    _isLoading = true;
    notifyListeners();
    
    _eventService.getEvents().listen(
      (eventList) {
        _events = eventList;
        
        // Filter events
        final now = DateTime.now();
        _upcomingEvents = eventList.where((event) => event.startDate.isAfter(now)).toList();
        _ongoingEvents = eventList.where((event) => 
            event.startDate.isBefore(now) && event.endDate.isAfter(now)).toList();
        _pastEvents = eventList.where((event) => event.endDate.isBefore(now)).toList();
        
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
  
  // Create event
  Future<void> createEvent(EventModel event) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.createEvent(event);
      
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
  
  // Update event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.updateEvent(eventId, event);
      
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
  
  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.deleteEvent(eventId);
      
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
  
  // Register for event
  Future<void> registerForEvent(String eventId, String volunteerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.registerForEvent(eventId, volunteerId);
      
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
  
  // Approve participant
  Future<void> approveParticipant(String eventId, String volunteerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.approveParticipant(eventId, volunteerId);
      
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
  
  // Reject participant
  Future<void> rejectParticipant(String eventId, String volunteerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _eventService.rejectParticipant(eventId, volunteerId);
      
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
// lib/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int maxParticipants;
  final List<String> registeredParticipants;
  final List<String> approvedParticipants;
  final String createdBy;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.maxParticipants,
    this.registeredParticipants = const [],
    this.approvedParticipants = const [],
    required this.createdBy,
    required this.createdAt,
  });

  // Check if event is upcoming
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  // Check if event is ongoing
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  // Check if event is past
  bool get isPast => DateTime.now().isAfter(endDate);

  // Get remaining slots
  int get remainingSlots => maxParticipants - approvedParticipants.length;

  // Convert Firestore document to EventModel
  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      location: map['location'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 0,
      registeredParticipants: List<String>.from(map['registeredParticipants'] ?? []),
      approvedParticipants: List<String>.from(map['approvedParticipants'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert EventModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'maxParticipants': maxParticipants,
      'registeredParticipants': registeredParticipants,
      'approvedParticipants': approvedParticipants,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  // Create a copy of EventModel with modified attributes
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? maxParticipants,
    List<String>? registeredParticipants,
    List<String>? approvedParticipants,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredParticipants: registeredParticipants ?? this.registeredParticipants,
      approvedParticipants: approvedParticipants ?? this.approvedParticipants,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mock data for UI development - can be removed when using Firestore
  static List<EventModel> getMockEvents() {
    final now = DateTime.now();
    
    return [
      EventModel(
        id: '1',
        title: 'Tree Plantation Drive',
        description: 'Join us for a tree plantation drive at the college campus. Bring your own gardening tools if possible.',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 5, hours: 4)),
        location: 'College Campus',
        maxParticipants: 50,
        registeredParticipants: ['1', '2', '3'],
        approvedParticipants: ['1', '2'],
        createdBy: '5',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      // Add other mock events as needed
    ];
  }
}
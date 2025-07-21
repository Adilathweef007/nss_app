import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String volunteerId;
  final String bloodGroup;
  final String place;
  final String department;
  final String role; // 'volunteer' or 'admin'
  final bool isApproved;
  final List<String> eventsParticipated;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.volunteerId,
    required this.bloodGroup,
    required this.place,
    required this.department,
    required this.role,
    this.isApproved = false,
    this.eventsParticipated = const [],
    required this.createdAt,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      place: map['place'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? 'volunteer',
      isApproved: map['isApproved'] ?? false,
      eventsParticipated: List<String>.from(map['eventsParticipated'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'volunteerId': volunteerId,
      'bloodGroup': bloodGroup,
      'place': place,
      'department': department,
      'role': role,
      'isApproved': isApproved,
      'eventsParticipated': eventsParticipated,
      'createdAt': createdAt,
    };
  }

  // Create a copy of UserModel with modified attributes
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? volunteerId,
    String? bloodGroup,
    String? place,
    String? department,
    String? role,
    bool? isApproved,
    List<String>? eventsParticipated,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      volunteerId: volunteerId ?? this.volunteerId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      place: place ?? this.place,
      department: department ?? this.department,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      eventsParticipated: eventsParticipated ?? this.eventsParticipated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  // Mock data for UI development
  static List<UserModel> getMockVolunteers() {
    return [
      UserModel(
        id: '1',
        name: 'Adil athweef P P',
        email: 'adilathweef777@gmail.com',
        volunteerId: 'NSS001',
        bloodGroup: 'AB-',
        place: 'Malappuram',
        department: 'Computer Application',
        role: 'volunteer',
        isApproved: true,
        eventsParticipated: ['1', '2'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: '2',
        name: 'Fuhad',
        email: 'fuhad@example.com',
        volunteerId: 'NSS002',
        bloodGroup: 'B+',
        place: 'Malappuram',
        department: 'Electronics',
        role: 'volunteer',
        isApproved: true,
        eventsParticipated: ['1'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      UserModel(
        id: '3',
        name: 'Anand',
        email: 'anand@example.com',
        volunteerId: 'NSS003',
        bloodGroup: 'O+',
        place: 'Malappuram',
        department: 'Mechanical',
        role: 'volunteer',
        isApproved: false,
        eventsParticipated: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // Mock data for pending approvals
  static List<UserModel> getMockPendingVolunteers() {
    return [
      UserModel(
        id: '3',
        name: 'Joel',
        email: 'Joel@example.com',
        volunteerId: 'NSS003',
        bloodGroup: 'A+',
        place: 'Alappuzha',
        department: 'Mechanical',
        role: 'volunteer',
        isApproved: false,
        eventsParticipated: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      UserModel(
        id: '4',
        name: 'Abhishaek',
        email: 'abhi@example.com',
        volunteerId: 'NSS004',
        bloodGroup: 'AB+',
        place: 'Kozhikode',
        department: 'Civil',
        role: 'volunteer',
        isApproved: false,
        eventsParticipated: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock data for admins
  static List<UserModel> getMockAdmins() {
    return [
      UserModel(
        id: '5',
        name: 'Dr. Shabeel',
        email: 'Shabeel@example.com',
        volunteerId: 'NSS-ADMIN-001',
        bloodGroup: 'A+',
        place: 'Kollam',
        department: 'Mathematics',
        role: 'admin',
        isApproved: true,
        eventsParticipated: [],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      UserModel(
        id: '6',
        name: 'Prof. Meena Sharma',
        email: 'meena.sharma@example.com',
        volunteerId: 'NSS-ADMIN-002',
        bloodGroup: 'B+',
        place: 'Kollam',
        department: 'Electronics',
        role: 'admin',
        isApproved: true,
        eventsParticipated: [],
        createdAt: DateTime.now().subtract(const Duration(days: 85)),
      ),
    ];
  }
}

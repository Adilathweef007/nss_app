import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/services/firebase_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
    } catch (e) {
      return null;
    }
  }
  
  // Get all volunteers
  Stream<List<UserModel>> getVolunteers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Get pending volunteers
  Stream<List<UserModel>> getPendingVolunteers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Get approved volunteers
  Stream<List<UserModel>> getApprovedVolunteers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Get all admins
  Stream<List<UserModel>> getAdmins() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  
  // Approve volunteer
  Future<void> approveVolunteer(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Reject volunteer
  Future<void> rejectVolunteer(String userId) async {
    try {
      // In a real app, you might want to move the user to a "rejected" collection
      // or just mark them as rejected instead of deleting
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  // Make user an admin
  Future<void> makeAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(String userId, {
    String? name,
    String? bloodGroup,
    String? place,
    String? department,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (bloodGroup != null) data['bloodGroup'] = bloodGroup;
      if (place != null) data['place'] = place;
      if (department != null) data['department'] = department;
      
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }
}
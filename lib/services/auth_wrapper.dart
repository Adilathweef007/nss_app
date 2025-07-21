import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nssapp/models/user_model.dart';

class AuthWrapper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simple sign in method to avoid pigeon issues
  static Future<bool> signInWithEmailPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Get user data safely
  static Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get role and approval status directly
  static Future<Map<String, dynamic>> getUserStatus() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return {'role': '', 'isApproved': false};

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return {'role': '', 'isApproved': false};

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'role': data['role'] ?? 'volunteer',
        'isApproved': data['isApproved'] ?? false
      };
    } catch (e) {
      print('Error getting user status: $e');
      return {'role': '', 'isApproved': false};
    }
  }

  // Sign out helper
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}

// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/services/firebase_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String volunteerId,
    required String bloodGroup,
    required String place,
    required String department,
  }) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'volunteerId': volunteerId,
        'bloodGroup': bloodGroup,
        'place': place,
        'department': department,
        'role': 'volunteer',
        'isApproved': false,
        'eventsParticipated': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If isAdmin is true, verify that the user is actually an admin
      if (isAdmin) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        
        if (!userDoc.exists || (userDoc.data() as Map<String, dynamic>)['role'] != 'admin') {
          await _auth.signOut();
          throw Exception('You do not have admin privileges');
        }
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted by user');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create user document for new Google sign in
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': result.user!.displayName ?? 'User',
          'email': result.user!.email ?? '',
          'volunteerId': 'G-${result.user!.uid.substring(0, 6)}',
          'bloodGroup': '',
          'place': '',
          'department': '',
          'role': 'volunteer',
          'isApproved': false,
          'eventsParticipated': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user role and approval status
  Future<Map<String, dynamic>> getUserRoleAndStatus() async {
    try {
      if (currentUser == null) {
        return {'role': '', 'isApproved': false};
      }
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        return {'role': '', 'isApproved': false};
      }
      
      final data = userDoc.data() as Map<String, dynamic>;
      
      return {
        'role': data['role'] ?? '',
        'isApproved': data['isApproved'] ?? false,
      };
    } catch (e) {
      print('Error getting user role and status: $e');
      return {'role': '', 'isApproved': false};
    }
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (!userDoc.exists || userDoc.data() == null) return null;
      
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }
}
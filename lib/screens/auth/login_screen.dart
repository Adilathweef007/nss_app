// lib/screens/auth/login_screen.dart (fixed)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:nssapp/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Direct Firebase Auth approach - bypass provider pattern
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // Step 1: Authenticate with Firebase
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user == null) {
          throw Exception("Authentication failed");
        }

        // Step 2: Get user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists || userDoc.data() == null) {
          throw Exception("User data not found");
        }

        // Step 3: Extract role and approval status
        final userData = userDoc.data() as Map<String, dynamic>;
        final role = userData['role'] as String? ?? 'volunteer';
        final isApproved = userData['isApproved'] as bool? ?? false;

        // Step 4: Admin validation
        if (role == 'admin' && !_isAdmin) {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage =
                'Please check "Login as Admin" to access admin features';
            _isLoading = false;
          });
          return;
        }

        if (_isAdmin && role != 'admin') {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = 'You do not have admin privileges';
            _isLoading = false;
          });
          return;
        }

        // Step 5: Navigation based on role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else if (role == 'volunteer' && !isApproved) {
          Navigator.pushReplacementNamed(context, '/pending-approval');
        } else {
          Navigator.pushReplacementNamed(context, '/volunteer/dashboard');
        }
      } on FirebaseAuthException catch (e) {
        print("Firebase Auth Error: ${e.code} - ${e.message}");
        setState(() {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'No user found with this email address';
              break;
            case 'wrong-password':
              _errorMessage = 'Incorrect password';
              break;
            case 'invalid-email':
              _errorMessage = 'Invalid email format';
              break;
            case 'user-disabled':
              _errorMessage = 'This account has been disabled';
              break;
            default:
              _errorMessage = 'Authentication failed: ${e.message}';
          }
        });
      } catch (e) {
        print("General Error: $e");
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Direct Google sign-in implementation
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception("Google authentication failed");
      }

      // Check if this is a new user
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user document for Google sign-in
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'volunteerId': 'G-${userCredential.user!.uid.substring(0, 6)}',
          'bloodGroup': '',
          'place': '',
          'department': '',
          'role': 'volunteer',
          'isApproved': false,
          'eventsParticipated': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Redirect to pending approval
        Navigator.pushReplacementNamed(context, '/pending-approval');
        return;
      }

      // For existing users, get role and approval status
      final userData = userDoc.data();
      if (userData == null) {
        throw Exception("User data is null");
      }

      final role = userData['role'] as String? ?? 'volunteer';
      final isApproved = userData['isApproved'] as bool? ?? false;

      // Admin validation for Google Sign-in
      if (role == 'admin' && !_isAdmin) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _errorMessage =
              'Please check "Login as Admin" to access admin features';
          _isLoading = false;
        });
        return;
      }

      // Navigate based on role and approval
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (role == 'volunteer' && !isApproved) {
        Navigator.pushReplacementNamed(context, '/pending-approval');
      } else {
        Navigator.pushReplacementNamed(context, '/volunteer/dashboard');
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      setState(() {
        _errorMessage =
            'Google Sign-In failed: ${e.toString().split('] ').last}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Header
                  const Icon(
                    Icons.volunteer_activism,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NSS App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'National Service Scheme',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    suffixIcon: Icons.email,  // Added required parameter
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    suffixIcon: Icons.visibility_off,  // Added required parameter
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Admin Switch
                  Row(
                    children: [
                      Checkbox(
                        value: _isAdmin,
                        onChanged: (value) {
                          setState(() {
                            _isAdmin = value ?? false;
                          });
                        },
                      ),
                      const Text('Login as Admin'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In Button
                  CustomButton(
                    text: 'Sign in with Google',
                    icon: Icons.g_mobiledata,
                    color: Colors.white,
                    textColor: Colors.black87,
                    isLoading: _isLoading,
                    onPressed: _googleSignIn,
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
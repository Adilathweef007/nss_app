// lib/screens/auth/signup_screen.dart (fixed for CustomTextField)
import 'package:flutter/material.dart';
import 'package:nssapp/providers/user_provider.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:nssapp/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _volunteerIdController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _placeController = TextEditingController();
  final _departmentController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Available blood groups
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Available departments
  final List<String> _departments = [
    'Computer Science', 'Electronics', 'Mechanical', 'Civil', 
    'Electrical', 'Information Technology', 'Computer Application', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _volunteerIdController.dispose();
    _bloodGroupController.dispose();
    _placeController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _showBloodGroupPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_bloodGroups[index]),
                onTap: () {
                  setState(() {
                    _bloodGroupController.text = _bloodGroups[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDepartmentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _departments.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_departments[index]),
                onTap: () {
                  setState(() {
                    _departmentController.text = _departments[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Try direct Firebase authentication to avoid the PigeonUserDetails error
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        // Now create the user in Firestore using UserProvider
        await context.read<UserProvider>().signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          volunteerId: _volunteerIdController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          place: _placeController.text.trim(),
          department: _departmentController.text.trim(),
        );
        
        // Navigate to pending approval screen
        Navigator.pushReplacementNamed(context, '/pending-approval');
      } on FirebaseAuthException catch (e) {
        setState(() {
          switch (e.code) {
            case 'email-already-in-use':
              _errorMessage = 'This email is already registered';
              break;
            case 'invalid-email':
              _errorMessage = 'Invalid email format';
              break;
            case 'weak-password':
              _errorMessage = 'Password is too weak';
              break;
            default:
              _errorMessage = 'Registration failed: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill in all the required details',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                
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
                
                // Full Name Field
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person,
                  suffixIcon: Icons.person,  // Adding required parameter
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  suffixIcon: Icons.email,  // Adding required parameter
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
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock,
                  suffixIcon: Icons.visibility_off,  // Adding required parameter
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Volunteer ID Field
                const Text(
                  'Volunteer ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _volunteerIdController,
                  hintText: 'Enter your volunteer ID',
                  prefixIcon: Icons.badge,
                  suffixIcon: Icons.badge,  // Adding required parameter
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your volunteer ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Blood Group Field
                const Text(
                  'Blood Group',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showBloodGroupPicker,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _bloodGroupController,
                      hintText: 'Select your blood group',
                      prefixIcon: Icons.bloodtype,
                      suffixIcon: Icons.arrow_drop_down,  // Adding required parameter
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your blood group';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Place/Location Field
                const Text(
                  'Place',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _placeController,
                  hintText: 'Enter your place/location',
                  prefixIcon: Icons.location_on,
                  suffixIcon: Icons.location_on,  // Adding required parameter
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your place/location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Department Field
                const Text(
                  'Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showDepartmentPicker,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _departmentController,
                      hintText: 'Select your department',
                      prefixIcon: Icons.school,
                      suffixIcon: Icons.arrow_drop_down,  // Adding required parameter
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your department';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Sign Up Button
                CustomButton(
                  text: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _signUp,
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
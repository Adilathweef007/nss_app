import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:nssapp/widgets/common/custom_text_field.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _adminIdController;
  late TextEditingController _departmentController;
  
  bool _isEditing = false;
  bool _isSaving = false;
  
  // Mock admin for UI development
  final UserModel _currentAdmin = UserModel.getMockAdmins().first;
  
  // Available departments
  final List<String> _departments = [
    'Computer Science', 'Electronics', 'Mechanical', 'Civil', 
    'Electrical', 'Information Technology', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with admin data
    _nameController = TextEditingController(text: _currentAdmin.name);
    _emailController = TextEditingController(text: _currentAdmin.email);
    _adminIdController = TextEditingController(text: _currentAdmin.volunteerId);
    _departmentController = TextEditingController(text: _currentAdmin.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _adminIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successProfileUpdated),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  void _changePassword() {
    // Show change password dialog
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController currentPasswordController = TextEditingController();
        final TextEditingController newPasswordController = TextEditingController();
        final TextEditingController confirmPasswordController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: currentPasswordController,
                hintText: 'Current Password',
                prefixIcon: Icons.lock,
                suffixIcon: Icons.visibility_off,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: newPasswordController,
                hintText: 'New Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: Icons.visibility_off,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: Icons.visibility_off,
                isPassword: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate and change password
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() {
    // Navigate to login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _currentAdmin.name.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing) ...[
                      Text(
                        _currentAdmin.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentAdmin.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin ID: ${_currentAdmin.volunteerId}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Profile Form
              if (_isEditing) ...[
                const Text(
                  'Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person,
                  suffixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email,
                  suffixIcon: Icons.email,
                  readOnly: true, // Email cannot be changed
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Admin ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _adminIdController,
                  hintText: 'Admin ID',
                  prefixIcon: Icons.badge,
                  suffixIcon: Icons.badge,
                  readOnly: true, // Admin ID cannot be changed
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Department',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _departmentController,
                  hintText: 'Department',
                  prefixIcon: Icons.school,
                  suffixIcon: Icons.arrow_drop_down,
                  readOnly: true,
                  onTap: _showDepartmentPicker,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your department';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        color: Colors.white,
                        textColor: Colors.black87,
                        onPressed: _toggleEditing,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Profile Info Display
                _buildProfileInfoItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  label: 'Role',
                  value: 'Admin',
                ),
                _buildProfileInfoItem(
                  context,
                  icon: Icons.school,
                  label: 'Department',
                  value: _currentAdmin.department,
                ),
                _buildProfileInfoItem(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Joined On',
                  value: '${_currentAdmin.createdAt.day}/${_currentAdmin.createdAt.month}/${_currentAdmin.createdAt.year}',
                ),
                const SizedBox(height: 32),
                
                // Change Password Button
                CustomButton(
                  text: 'Change Password',
                  color: Colors.grey.shade200,
                  textColor: Colors.black87,
                  onPressed: _changePassword,
                ),
                const SizedBox(height: 16),
                
                // Sign Out Button
                CustomButton(
                  text: 'Sign Out',
                  color: Colors.red,
                  onPressed: _signOut,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:nssapp/widgets/common/custom_text_field.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _volunteerIdController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _placeController;
  late TextEditingController _departmentController;
  
  bool _isEditing = false;
  bool _isSaving = false;
  
  // Mock user for UI development
  final UserModel _currentUser = UserModel.getMockVolunteers().first;
  
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
  void initState() {
    super.initState();
    // Initialize controllers with user data
    _nameController = TextEditingController(text: _currentUser.name);
    _emailController = TextEditingController(text: _currentUser.email);
    _volunteerIdController = TextEditingController(text: _currentUser.volunteerId);
    _bloodGroupController = TextEditingController(text: _currentUser.bloodGroup);
    _placeController = TextEditingController(text: _currentUser.place);
    _departmentController = TextEditingController(text: _currentUser.department);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _volunteerIdController.dispose();
    _bloodGroupController.dispose();
    _placeController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
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
                        _currentUser.name.substring(0, 1),
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
                        _currentUser.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentUser.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Volunteer ID: ${_currentUser.volunteerId}',
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
                  suffixIcon: Icons.person, // Added required parameter
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
                  suffixIcon: Icons.email, // Added required parameter
                  readOnly: true, // Email cannot be changed
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Volunteer ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _volunteerIdController,
                  hintText: 'Volunteer ID',
                  prefixIcon: Icons.badge,
                  suffixIcon: Icons.badge, // Added required parameter
                  readOnly: true, // Volunteer ID cannot be changed
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Blood Group',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _bloodGroupController,
                  hintText: 'Blood Group',
                  prefixIcon: Icons.bloodtype,
                  suffixIcon: Icons.arrow_drop_down, // Added required parameter
                  readOnly: true,
                  onTap: _showBloodGroupPicker,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your blood group';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Place',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _placeController,
                  hintText: 'Place',
                  prefixIcon: Icons.location_on,
                  suffixIcon: Icons.location_on, // Added required parameter
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your place';
                    }
                    return null;
                  },
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
                  suffixIcon: Icons.arrow_drop_down, // Added required parameter
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
                  icon: Icons.bloodtype,
                  label: 'Blood Group',
                  value: _currentUser.bloodGroup,
                ),
                _buildProfileInfoItem(
                  context,
                  icon: Icons.location_on,
                  label: 'Place',
                  value: _currentUser.place,
                ),
                _buildProfileInfoItem(
                  context,
                  icon: Icons.school,
                  label: 'Department',
                  value: _currentUser.department,
                ),
                _buildProfileInfoItem(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Joined On',
                  value: '${_currentUser.createdAt.day}/${_currentUser.createdAt.month}/${_currentUser.createdAt.year}',
                ),
                const SizedBox(height: 32),
                
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
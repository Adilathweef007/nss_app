import 'package:flutter/material.dart';
import 'package:nssapp/models/user_model.dart';
import 'package:nssapp/utils/constants.dart';
import 'package:nssapp/widgets/common/custom_button.dart';
import 'package:nssapp/widgets/common/custom_text_field.dart';

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({Key? key}) : super(key: key);

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminIdController = TextEditingController();
  final _departmentController = TextEditingController();
  
  bool _isLoading = false;
  List<UserModel> _volunteers = [];
  UserModel? _selectedVolunteer;
  bool _isExistingVolunteer = false;
  
  // Available departments
  final List<String> _departments = [
    'Computer Science', 'Electronics', 'Mechanical', 'Civil', 
    'Electrical', 'Information Technology', 'Computer Application', 'Other'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
  
  void _loadVolunteers() {
    // Get all approved volunteers
    _volunteers = UserModel.getMockVolunteers()
        .where((volunteer) => volunteer.isApproved)
        .toList();
  }
  
  void _selectVolunteer(UserModel? volunteer) {
    setState(() {
      _selectedVolunteer = volunteer;
      
      if (volunteer != null) {
        _nameController.text = volunteer.name;
        _emailController.text = volunteer.email;
        _adminIdController.text = 'NSS-ADMIN-${volunteer.volunteerId}';
        _departmentController.text = volunteer.department;
      } else {
        _nameController.clear();
        _emailController.clear();
        _adminIdController.clear();
        _departmentController.clear();
      }
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
  
  void _addAdmin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successAdminAdded),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to admin list
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Admin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing Volunteer Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Is this admin an existing volunteer?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isExistingVolunteer,
                            onChanged: (value) {
                              setState(() {
                                _isExistingVolunteer = value;
                                if (!value) {
                                  _selectVolunteer(null);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isExistingVolunteer) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select Volunteer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<UserModel>(
                          value: _selectedVolunteer,
                          hint: const Text('Select a volunteer'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: _volunteers.map((volunteer) {
                            return DropdownMenuItem<UserModel>(
                              value: volunteer,
                              child: Text('${volunteer.name} (${volunteer.volunteerId})'),
                            );
                          }).toList(),
                          onChanged: _selectVolunteer,
                          validator: _isExistingVolunteer
                              ? (value) {
                                  if (value == null) {
                                    return 'Please select a volunteer';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Admin Details
              const Text(
                'Admin Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
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
                readOnly: _isExistingVolunteer && _selectedVolunteer != null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter admin name';
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
                hintText: 'Email',
                prefixIcon: Icons.email,
                suffixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                readOnly: _isExistingVolunteer && _selectedVolunteer != null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field (only for new admins)
              if (!_isExistingVolunteer) ...[
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  suffixIcon: Icons.visibility_off,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // Admin ID Field
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter admin ID';
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
              CustomTextField(
                controller: _departmentController,
                hintText: 'Department',
                prefixIcon: Icons.school,
                suffixIcon: Icons.arrow_drop_down,
                readOnly: true,
                onTap: _isExistingVolunteer && _selectedVolunteer != null ? null : _showDepartmentPicker,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Add Button
              CustomButton(
                text: 'Add Admin',
                isLoading: _isLoading,
                onPressed: _addAdmin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
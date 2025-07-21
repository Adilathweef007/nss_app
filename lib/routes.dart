import 'package:flutter/material.dart';

// Auth Screens
import 'package:nssapp/screens/auth/login_screen.dart';
import 'package:nssapp/screens/auth/signup_screen.dart';
import 'package:nssapp/screens/auth/pending_approval_screen.dart';

// Volunteer Screens
import 'package:nssapp/screens/volunteer/volunteer_dashboard.dart';
import 'package:nssapp/screens/volunteer/volunteer_profile_screen.dart';
import 'package:nssapp/screens/volunteer/event_list_screen.dart';
import 'package:nssapp/screens/volunteer/event_details_screen.dart';
import 'package:nssapp/screens/volunteer/attendance_status_screen.dart';

// Admin Screens
import 'package:nssapp/screens/admin/admin_dashboard.dart';
import 'package:nssapp/screens/admin/admin_profile_screen.dart';
import 'package:nssapp/screens/admin/volunteer_management/volunteer_list_screen.dart';
import 'package:nssapp/screens/admin/volunteer_management/volunteer_details_screen.dart';
import 'package:nssapp/screens/admin/volunteer_management/pending_approvals_screen.dart';
import 'package:nssapp/screens/admin/volunteer_management/attendance_management_screen.dart';
import 'package:nssapp/screens/admin/event_management/create_event_screen.dart';
import 'package:nssapp/screens/admin/event_management/event_list_screen.dart';
import 'package:nssapp/screens/admin/event_management/event_details_screen.dart';
import 'package:nssapp/screens/admin/admin_management/add_admin_screen.dart';
import 'package:nssapp/screens/admin/admin_management/admin_list_screen.dart';

// Define routes
final Map<String, WidgetBuilder> routes = {
  // Auth Routes
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/pending-approval': (context) => const PendingApprovalScreen(),
  
  // Volunteer Routes
  '/volunteer/dashboard': (context) => const VolunteerDashboard(),
  '/volunteer/profile': (context) => const VolunteerProfileScreen(),
  '/volunteer/events': (context) => const VolunteerEventListScreen(),
  '/volunteer/event-details': (context) => const VolunteerEventDetailsScreen(),
  '/volunteer/attendance': (context) => const AttendanceStatusScreen(),
  
  // Admin Routes
  '/admin/dashboard': (context) => const AdminDashboard(),
  '/admin/profile': (context) => const AdminProfileScreen(),
  '/admin/volunteers': (context) => const VolunteerListScreen(),
  '/admin/volunteer-details': (context) => const VolunteerDetailsScreen(),
  '/admin/pending-approvals': (context) => const PendingApprovalsScreen(),
  '/admin/attendance-management': (context) => const AttendanceManagementScreen(),
  '/admin/create-event': (context) => const CreateEventScreen(),
  '/admin/events': (context) => const AdminEventListScreen(),
  '/admin/event-details': (context) => const AdminEventDetailsScreen(),
  '/admin/add-admin': (context) => const AddAdminScreen(),
  '/admin/admins': (context) => const AdminListScreen(),
};
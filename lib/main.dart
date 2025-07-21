// lib/main.dart (fixed)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nssapp/providers/attendance_provider.dart';
import 'package:nssapp/providers/event_provider.dart';
import 'package:nssapp/providers/user_provider.dart';
import 'package:nssapp/providers/volunteer_provider.dart';
import 'package:nssapp/routes.dart';
import 'package:nssapp/screens/auth/login_screen.dart';
import 'package:nssapp/services/firebase_service.dart';
import 'package:nssapp/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();
  
  // Force clear any persistent auth state - may help with the PigeonUserDetails error
  await FirebaseAuth.instance.signOut();
  
  // Add auth state listener for debugging
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    print("Auth state changed: ${user?.email ?? 'No user'}");
  });
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => VolunteerProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const NSSApp(),
    ),
  );
}

class NSSApp extends StatelessWidget {
  const NSSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSS App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routes: routes,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use select instead of watch for more specific rebuilds
    final authStatus = context.select<UserProvider, AuthStatus>((provider) => provider.status);
    final role = context.select<UserProvider, String>((provider) => provider.role);

    // Print for debugging
    print("AuthWrapper: Status = $authStatus, Role = $role");

    // Use conditional rendering instead of navigation in build method
    switch (authStatus) {
      case AuthStatus.uninitialized:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
        // IMPORTANT: Schedule navigation after build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/volunteer/dashboard');
          }
        });
        
        // Return loading screen while navigation is pending
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.pendingApproval:
        // IMPORTANT: Schedule navigation after build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/pending-approval');
        });
        
        // Return loading screen while navigation is pending
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.unauthenticated:
      default:
        return const LoginScreen();
    }
  }
}
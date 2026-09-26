import 'package:employee_management_app/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/employee_list_screen.dart';
import 'login_screen.dart';

/// Decides the first screen from the Firebase auth state, so a
/// signed-in user skips Login on relaunch.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isAuthenticated
            ? const EmployeeListScreen()
            : const LoginScreen();
      },
    );
  }
}
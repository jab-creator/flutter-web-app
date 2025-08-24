import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder<User>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data ?? User.empty;

        if (user.isNotEmpty) {
          return HomeScreen(
            user: user,
            onLogout: () async {
              try {
                await authService.logOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error signing out. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
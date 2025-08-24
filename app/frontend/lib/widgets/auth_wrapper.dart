import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    
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
          // Check if user needs onboarding (no children created yet)
          return FutureBuilder<List<dynamic>>(
            future: firestoreService.getChildrenForUser(user.id),
            builder: (context, childrenSnapshot) {
              if (childrenSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final children = childrenSnapshot.data ?? [];
              
              // If user has no children, show onboarding
              if (children.isEmpty) {
                return const OnboardingScreen();
              }

              // User has children, show main app
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
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    setState(() {
      _isLoggedIn = AuthService.isLoggedIn;
      _currentUser = AuthService.currentUser;
    });
  }

  void _login(String username) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = username;
    });
  }

  void _logout() {
    AuthService.logout();
    setState(() {
      _isLoggedIn = false;
      _currentUser = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return HomeScreen(
        currentUser: _currentUser,
        onLogout: _logout,
      );
    } else {
      return LoginScreen(onLogin: _login);
    }
  }
}
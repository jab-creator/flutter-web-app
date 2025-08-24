class AuthService {
  static bool _isLoggedIn = false;
  static String _currentUser = '';

  static bool get isLoggedIn => _isLoggedIn;
  static String get currentUser => _currentUser;

  static Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple validation - in real app, this would be server-side
    if (username.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _currentUser = username;
      return true;
    }
    return false;
  }

  static void logout() {
    _isLoggedIn = false;
    _currentUser = '';
  }
}
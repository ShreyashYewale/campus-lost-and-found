import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService apiService;
  
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;
  bool _isAuthenticated = false;

  AuthService({required this.apiService}) {
    _initializeAuth();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      final mutation = r'''
        mutation CreateUser($name: String!, $email: String!, $password: String!) {
          createUser(data: { name: $name, email: $email, password: $password }) {
            id
            name
            email
          }
        }
      ''';

      final result = await apiService.mutation(
        mutation,
        variables: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final newUser = result['createUser'] as Map<String, dynamic>?;
      if (newUser == null) return false;

      _userId = newUser['id'] as String;
      _userName = newUser['name'] ?? name;
      _userEmail = email;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'local_session_$_userId');
      await prefs.setString('user_id', _userId!);
      await prefs.setString('user_name', _userName!);
      await prefs.setString('user_email', _userEmail!);

      notifyListeners();
      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final mutation = r'''
        mutation AuthenticateUserWithPassword($email: String!, $password: String!) {
          authenticateUserWithPassword(email: $email, password: $password) {
            ... on UserAuthenticationWithPasswordSuccess {
              sessionToken
              item {
                id
                name
                email
              }
            }
            ... on UserAuthenticationWithPasswordFailure {
              message
            }
          }
        }
      ''';

      final result = await apiService.mutation(
        mutation,
        variables: {
          'email': email,
          'password': password,
        },
      );

      final authResult = result['authenticateUserWithPassword'] as Map<String, dynamic>?;
      if (authResult == null) return false;

      if (authResult['sessionToken'] != null) {
        final item = authResult['item'] as Map<String, dynamic>;
        _token = authResult['sessionToken'] as String;
        _userId = item['id'] as String;
        _userName = item['name'] ?? email.split('@')[0];
        _userEmail = email;
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _userId!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    notifyListeners();
  }
}

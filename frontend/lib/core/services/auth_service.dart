import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService apiService;
  
  String? _token;
  String? _userId;
  bool _isAuthenticated = false;

  AuthService({required this.apiService}) {
    _initializeAuth();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> googleSignIn(String idToken) async {
    try {
      const mutation = '''
        mutation GoogleSignIn(\$idToken: String!) {
          googleSignIn(idToken: \$idToken) {
            token
            user {
              id
              email
              name
            }
          }
        }
      ''';

      final result = await apiService.mutation(
        mutation,
        variables: {'idToken': idToken},
      );

      if (result.containsKey('googleSignIn')) {
        final data = result['googleSignIn'];
        _token = data['token'];
        _userId = data['user']['id'];
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _userId!);

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
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    notifyListeners();
  }
}

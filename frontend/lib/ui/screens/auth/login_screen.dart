import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:campus_lost_found/config/app_config.dart';
import 'package:campus_lost_found/core/utils/email_validator.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isSignUp = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Sign In')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  Text(
                    _isSignUp ? 'Create an account' : 'Sign in to your account',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Join Campus Lost & Found with your @campus.edu email'
                        : 'Post and claim items on campus',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (_isSignUp)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  if (_isSignUp) const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (_isSignUp) {
                        return EmailValidator.validationMessage(
                          value,
                          allowedDomains: AppConfig.dev().allowedEmailDomains,
                        );
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSubmit,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(_isSignUp ? Icons.person_add : Icons.login),
                      label: Text(_isLoading ? 'Please wait...' : (_isSignUp ? 'Sign Up' : 'Sign In')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: Text(_isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      bool success;

      if (_isSignUp) {
        success = await authService.signUp(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isSignUp ? 'Account created!' : 'Sign in successful!')),
          );
          context.go('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isSignUp
                    ? 'Sign up failed. Use a @campus.edu email or try again.'
                    : 'Invalid email or password.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

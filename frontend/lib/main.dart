import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (no dotenv for web)
  final apiService = ApiService(
    baseUrl: 'http://localhost:4000/graphql',
  );
  
  final authService = AuthService(apiService: apiService);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => AuthService(apiService: apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

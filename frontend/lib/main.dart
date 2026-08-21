import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/item_service.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.dev();
  final apiService = ApiService(
    baseUrl: config.apiBaseUrl,
    apiOrigin: config.apiOrigin,
  );
  final authService = AuthService(apiService: apiService);
  await authService.ensureInitialized();
  final itemService = ItemService(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<ItemService>.value(value: itemService),
      ],
      child: const MyApp(),
    ),
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus_lost_found/config/app_config.dart';
import 'package:campus_lost_found/core/services/api_service.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/item_service.dart';
import 'package:campus_lost_found/ui/app.dart';

void main() {
  testWidgets('The app shows the home screen with key actions', (tester) async {
    final config = AppConfig.dev();
    final apiService = ApiService(baseUrl: config.apiBaseUrl);
    final authService = AuthService(apiService: apiService);
    final itemService = ItemService(apiService: apiService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider<AuthService>.value(value: authService),
          Provider<ItemService>.value(value: itemService),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Campus Lost & Found'), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Browse Items'), findsOneWidget);
    expect(find.text('Post an Item'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}

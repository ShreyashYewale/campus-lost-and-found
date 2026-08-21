import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/items/post_item_screen.dart';
import 'screens/items/item_detail_screen.dart';
import 'screens/items/search_items_screen.dart';
import 'screens/notifications_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Lost & Found',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _buildRouter(),
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) => const PostItemScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchItemsScreen(),
        ),
        GoRoute(
          path: '/item/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ItemDetailScreen(itemId: id);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
      initialLocation: '/',
    );
  }
}

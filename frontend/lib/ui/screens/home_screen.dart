import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated) return;

    try {
      final count = await context.read<NotificationService>().fetchUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Find or post lost and found items on campus',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.list),
                    label: const Text('Browse Items'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/post'),
                    icon: const Icon(Icons.add),
                    label: const Text('Post an Item'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    if (!authService.isAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await context.push('/notifications');
                              if (mounted) _loadUnreadCount();
                            },
                            icon: const Icon(Icons.notifications),
                            label: Text(
                              _unreadCount > 0
                                  ? 'Notifications ($_unreadCount unread)'
                                  : 'Notifications',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    if (authService.isAuthenticated) {
                      return Column(
                        children: [
                          Text(
                            'Signed in as ${authService.userEmail ?? 'User'}',
                            style: const TextStyle(color: Colors.green),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await authService.logout();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Logged out successfully')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                            ),
                          ),
                        ],
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.person),
                        label: const Text('Sign In'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

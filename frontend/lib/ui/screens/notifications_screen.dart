import 'package:campus_lost_found/core/models/app_notification.dart';
import 'package:campus_lost_found/core/services/api_service.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/claim_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shows the signed-in user their notifications. This is where a claimant
/// (e.g. Bob) sees the OTP after their claim is approved.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _error;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    await auth.ensureInitialized();
    if (!auth.isAuthenticated || auth.token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please sign in to see your notifications.';
      });
      return;
    }

    try {
      context.read<ApiService>().setSessionToken(auth.token);
      final claimService = context.read<ClaimService>();
      final items = await claimService.fetchMyNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'claim_approved':
        return Icons.verified_user;
      case 'claim':
        return Icons.assignment_ind;
      case 'match':
        return Icons.compare_arrows;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push('/login'),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications yet.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final n = _notifications[i];
                          final isOtp = n.type == 'claim_approved';
                          return Card(
                            color: isOtp ? Colors.green.shade50 : null,
                            child: ListTile(
                              leading: Icon(
                                _iconFor(n.type),
                                color: isOtp ? Colors.green : Colors.blueGrey,
                              ),
                              title: Text(n.message),
                              subtitle: isOtp
                                  ? const Text('Show this OTP to the finder to collect your item.')
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
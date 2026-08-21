import 'package:campus_lost_found/core/offline/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ItemRepository, SyncService>(
      builder: (context, repository, syncService, child) {
        if (repository.isOnline && repository.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        final message = repository.isOnline
            ? 'Syncing ${repository.pendingCount} pending change(s)...'
            : 'Offline mode — showing saved items (${repository.pendingCount} pending)';

        return MaterialBanner(
          content: Text(message),
          leading: Icon(
            repository.isOnline ? Icons.sync : Icons.cloud_off,
            color: repository.isOnline ? Colors.blue : Colors.orange,
          ),
          actions: [
            if (repository.isOnline)
              TextButton(
                onPressed: syncService.syncPendingOperations,
                child: const Text('Sync now'),
              ),
          ],
        );
      },
    );
  }
}

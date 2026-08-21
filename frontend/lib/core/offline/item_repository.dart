import 'package:campus_lost_found/core/models/item.dart';
import 'package:campus_lost_found/core/offline/connectivity_service.dart';
import 'package:campus_lost_found/core/offline/local_cache_service.dart';
import 'package:campus_lost_found/core/offline/pending_sync_service.dart';
import 'package:campus_lost_found/core/services/item_service.dart';
import 'package:flutter/foundation.dart';

class SyncService extends ChangeNotifier {
  final ItemService itemService;
  final LocalCacheService localCache;
  final PendingSyncService pendingSync;
  final ConnectivityService connectivity;

  bool _isSyncing = false;

  SyncService({
    required this.itemService,
    required this.localCache,
    required this.pendingSync,
    required this.connectivity,
  }) {
    connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendingOperations();
      }
      notifyListeners();
    });
  }

  bool get isSyncing => _isSyncing;
  bool get isOnline => connectivity.isOnline;
  int get pendingCount => pendingSync.pendingCount;

  Future<void> refreshItemsCache() async {
    if (!connectivity.isOnline) return;

    final items = await itemService.fetchItems();
    await localCache.cacheItems(items);
    notifyListeners();
  }

  Future<void> syncPendingOperations() async {
    if (!connectivity.isOnline || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final operations = pendingSync.getPendingOperations();
      for (final operation in operations) {
        switch (operation.type) {
          case PendingOperationType.createItem:
            final payload = operation.payload;
            final success = await itemService.createItem(
              title: payload['title'] as String,
              description: payload['description'] as String,
              type: payload['type'] as String,
              category: payload['category'] as String,
              location: payload['location'] as String,
              postedById: payload['postedById'] as String,
            );
            if (success) {
              await pendingSync.remove(operation.id);
            }
            break;
          case PendingOperationType.createClaim:
            final payload = operation.payload;
            final success = await itemService.createClaim(
              itemId: payload['itemId'] as String,
              claimantId: payload['claimantId'] as String,
              message: (payload['message'] as String?) ?? '',
            );
            if (success) {
              await pendingSync.remove(operation.id);
            }
            break;
        }
      }

      await refreshItemsCache();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

class ItemRepository extends ChangeNotifier {
  final ItemService itemService;
  final LocalCacheService localCache;
  final PendingSyncService pendingSync;
  final SyncService syncService;

  ItemRepository({
    required this.itemService,
    required this.localCache,
    required this.pendingSync,
    required this.syncService,
  });

  bool get isOnline => syncService.isOnline;
  int get pendingCount => syncService.pendingCount;

  Future<List<Item>> fetchItems() async {
    if (syncService.isOnline) {
      try {
        final items = await itemService.fetchItems();
        await localCache.cacheItems(items);
        notifyListeners();
        return items;
      } catch (_) {
        return localCache.getCachedItems();
      }
    }

    return localCache.getCachedItems();
  }

  Future<Item?> fetchItemById(String id) async {
    if (syncService.isOnline) {
      try {
        final item = await itemService.fetchItemById(id);
        if (item != null) {
          await localCache.cacheItem(item);
        }
        return item;
      } catch (_) {
        return localCache.getCachedItem(id);
      }
    }

    return localCache.getCachedItem(id);
  }

  Future<bool> createItem({
    required String title,
    required String description,
    required String type,
    required String category,
    required String location,
    required String postedById,
  }) async {
    if (syncService.isOnline) {
      final success = await itemService.createItem(
        title: title,
        description: description,
        type: type,
        category: category,
        location: location,
        postedById: postedById,
      );
      if (success) {
        await syncService.refreshItemsCache();
      }
      return success;
    }

    await pendingSync.enqueueCreateItem({
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'postedById': postedById,
    });

    final optimisticItem = Item(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type == 'found' ? ItemType.found : ItemType.lost,
      category: ItemCategory.fromApiValue(category),
      location: location,
      status: ItemStatus.open,
      createdAt: DateTime.now(),
      postedById: postedById,
    );
    await localCache.cacheItem(optimisticItem);
    notifyListeners();
    return true;
  }

  Future<bool> createClaim({
    required String itemId,
    required String claimantId,
    String message = '',
  }) async {
    if (syncService.isOnline) {
      return itemService.createClaim(
        itemId: itemId,
        claimantId: claimantId,
        message: message,
      );
    }

    await pendingSync.enqueueCreateClaim({
      'itemId': itemId,
      'claimantId': claimantId,
      'message': message,
    });
    notifyListeners();
    return true;
  }
}

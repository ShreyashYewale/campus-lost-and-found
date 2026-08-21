import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'core/offline/connectivity_service.dart';
import 'core/offline/item_repository.dart';
import 'core/offline/local_cache_service.dart';
import 'core/offline/pending_sync_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/item_service.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final config = AppConfig.dev();
  final apiService = ApiService(baseUrl: config.apiBaseUrl);
  final authService = AuthService(apiService: apiService);
  final itemService = ItemService(apiService: apiService);

  final connectivityService = ConnectivityService();
  final localCacheService = LocalCacheService();
  final pendingSyncService = PendingSyncService();

  await connectivityService.initialize();
  await localCacheService.initialize();
  await pendingSyncService.initialize();

  final syncService = SyncService(
    itemService: itemService,
    localCache: localCacheService,
    pendingSync: pendingSyncService,
    connectivity: connectivityService,
  );

  final itemRepository = ItemRepository(
    itemService: itemService,
    localCache: localCacheService,
    pendingSync: pendingSyncService,
    syncService: syncService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<ItemService>.value(value: itemService),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
        ChangeNotifierProvider<ItemRepository>.value(value: itemRepository),
      ],
      child: const MyApp(),
    ),
  );
}

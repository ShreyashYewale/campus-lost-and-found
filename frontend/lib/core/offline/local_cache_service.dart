import 'package:campus_lost_found/core/models/item.dart';
import 'package:hive/hive.dart';

class LocalCacheService {
  static const _itemsBoxName = 'cached_items';

  Box<Map>? _itemsBox;

  Future<void> initialize() async {
    _itemsBox = await Hive.openBox<Map>(_itemsBoxName);
  }

  List<Item> getCachedItems() {
    final box = _itemsBox;
    if (box == null) return const [];

    return box.values
        .map((entry) => Item.fromJson(Map<String, dynamic>.from(entry)))
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  Item? getCachedItem(String id) {
    final box = _itemsBox;
    if (box == null || !box.containsKey(id)) return null;
    final entry = box.get(id);
    if (entry == null) return null;
    return Item.fromJson(Map<String, dynamic>.from(entry));
  }

  Future<void> cacheItems(List<Item> items) async {
    final box = _itemsBox;
    if (box == null) return;

    for (final item in items) {
      await box.put(item.id, item.toJson());
    }
  }

  Future<void> cacheItem(Item item) async {
    final box = _itemsBox;
    if (box == null) return;
    await box.put(item.id, item.toJson());
  }
}

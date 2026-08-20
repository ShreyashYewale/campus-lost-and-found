import 'package:intl/intl.dart';

enum ItemType { lost, found }

enum ItemStatus { open, claimed, resolved }

enum ItemCategory {
  electronics,
  idCards,
  keys,
  bags,
  books,
  clothing,
  other;

  static ItemCategory fromApiValue(String value) {
    switch (value) {
      case 'electronics':
        return ItemCategory.electronics;
      case 'id_cards':
        return ItemCategory.idCards;
      case 'keys':
        return ItemCategory.keys;
      case 'bags':
        return ItemCategory.bags;
      case 'books':
        return ItemCategory.books;
      case 'clothing':
        return ItemCategory.clothing;
      default:
        return ItemCategory.other;
    }
  }

  String get apiValue {
    switch (this) {
      case ItemCategory.idCards:
        return 'id_cards';
      default:
        return name;
    }
  }

  String get displayName {
    switch (this) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.idCards:
        return 'ID / Cards';
      case ItemCategory.keys:
        return 'Keys';
      case ItemCategory.bags:
        return 'Bags';
      case ItemCategory.books:
        return 'Books / Stationery';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.other:
        return 'Other';
    }
  }
}

class Item {
  final String id;
  final String title;
  final String description;
  final String? photoUrl;
  final ItemType type;
  final ItemCategory category;
  final String location;
  final ItemStatus status;
  final DateTime? createdAt;
  final String? postedById;
  final String? postedByName;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.photoUrl,
    required this.type,
    required this.category,
    required this.location,
    required this.status,
    this.createdAt,
    this.postedById,
    this.postedByName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? '').toString();
    final rawCategory = (json['category'] ?? '').toString();
    final rawStatus = (json['status'] ?? '').toString();

    return Item(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photoUrl: _readPhotoUrl(json['photo']),
      type: ItemType.values.firstWhere(
        (value) => value.name == rawType,
        orElse: () => ItemType.lost,
      ),
      category: ItemCategory.fromApiValue(rawCategory),
      location: json['location']?.toString() ?? '',
      status: ItemStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => ItemStatus.open,
      ),
      createdAt: _parseDate(json['createdAt']),
      postedById: _readRelationId(json['postedBy']),
      postedByName: _readRelationName(json['postedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.apiValue,
      'location': location,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
      'postedBy': {
        'id': postedById,
        'name': postedByName,
      },
      'photo': photoUrl != null ? {'url': photoUrl} : null,
    };
  }

  static String? _readPhotoUrl(dynamic photo) {
    if (photo is Map<String, dynamic>) {
      final url = photo['url'];
      if (url is String && url.isNotEmpty) return url;
    }

    if (photo is Map) {
      final url = photo['url'];
      if (url is String && url.isNotEmpty) return url;
    }

    return null;
  }

  static String? _readRelationId(dynamic relation) {
    if (relation is Map<String, dynamic>) {
      return relation['id']?.toString();
    }
    if (relation is Map) {
      return relation['id']?.toString();
    }
    return null;
  }

  static String? _readRelationName(dynamic relation) {
    if (relation is Map<String, dynamic>) {
      final name = relation['name'];
      if (name is String && name.isNotEmpty) return name;
      final email = relation['email'];
      if (email is String && email.isNotEmpty) return email;
    }
    if (relation is Map) {
      final name = relation['name'];
      if (name is String && name.isNotEmpty) return name;
      final email = relation['email'];
      if (email is String && email.isNotEmpty) return email;
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String get formattedDate => createdAt == null
      ? ''
      : DateFormat('MMM dd, yyyy').format(createdAt!);

  String get formattedTime => createdAt == null
      ? ''
      : DateFormat('hh:mm a').format(createdAt!);
}

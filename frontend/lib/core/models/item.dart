import 'package:intl/intl.dart';

enum ItemStatus { found, lost, claimed, resolved }

enum ItemCategory {
  electronics,
  accessories,
  clothing,
  documents,
  bags,
  keys,
  other,
}

class Item {
  final String id;
  final String title;
  final String description;
  final String photoUrl;
  final ItemCategory category;
  final ItemStatus status;
  final double latitude;
  final double longitude;
  final String location;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? claimedBy;
  final DateTime? claimedAt;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.category,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
    this.claimedBy,
    this.claimedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      category: ItemCategory.values.byName(json['category']),
      status: ItemStatus.values.byName(json['status']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      userId: json['userId'],
      userName: json['userName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      claimedBy: json['claimedBy'],
      claimedAt: json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'category': category.name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'claimedBy': claimedBy,
      'claimedAt': claimedAt?.toIso8601String(),
    };
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt);
  String get formattedTime => DateFormat('hh:mm a').format(createdAt);
}

import 'package:intl/intl.dart';

enum NotificationType { match, claim, claimApproved, claimRejected, unknown }

class AppNotification {
  final String id;
  final NotificationType type;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String? relatedItemId;
  final String? relatedItemTitle;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.relatedItemId,
    this.relatedItemTitle,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? '').toString();
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: _parseType(rawType),
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: _parseDate(json['createdAt']),
      relatedItemId: _readRelationId(json['relatedItem']),
      relatedItemTitle: _readRelationTitle(json['relatedItem']),
    );
  }

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'match':
        return NotificationType.match;
      case 'claim':
        return NotificationType.claim;
      case 'claim_approved':
        return NotificationType.claimApproved;
      case 'claim_rejected':
        return NotificationType.claimRejected;
      default:
        return NotificationType.unknown;
    }
  }

  static String? _readRelationId(dynamic relation) {
    if (relation is Map) return relation['id']?.toString();
    return null;
  }

  static String? _readRelationTitle(dynamic relation) {
    if (relation is Map) return relation['title']?.toString();
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
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
      : DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt!);

  String get typeLabel {
    switch (type) {
      case NotificationType.match:
        return 'Possible Match';
      case NotificationType.claim:
        return 'New Claim';
      case NotificationType.claimApproved:
        return 'Claim Approved';
      case NotificationType.claimRejected:
        return 'Claim Rejected';
      case NotificationType.unknown:
        return 'Notification';
    }
  }
}

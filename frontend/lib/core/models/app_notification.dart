/// An in-app notification (match, claim, approval-with-OTP, etc.).
class AppNotification {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final String? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: (json['type'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] as String?,
    );
  }
}
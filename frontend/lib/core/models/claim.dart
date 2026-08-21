enum ClaimStatus { pending, approved, rejected }

class Claim {
  final String id;
  final ClaimStatus status;
  final String message;
  final String? claimantId;
  final String? claimantName;
  final DateTime? createdAt;

  Claim({
    required this.id,
    required this.status,
    required this.message,
    this.claimantId,
    this.claimantName,
    this.createdAt,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'pending').toString();
    return Claim(
      id: json['id']?.toString() ?? '',
      status: ClaimStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => ClaimStatus.pending,
      ),
      message: json['message']?.toString() ?? '',
      claimantId: _readRelationId(json['claimant']),
      claimantName: _readRelationName(json['claimant']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String? _readRelationId(dynamic relation) {
    if (relation is Map) return relation['id']?.toString();
    return null;
  }

  static String? _readRelationName(dynamic relation) {
    if (relation is Map) {
      final name = relation['name'];
      if (name is String && name.isNotEmpty) return name;
      final email = relation['email'];
      if (email is String && email.isNotEmpty) return email;
    }
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
}

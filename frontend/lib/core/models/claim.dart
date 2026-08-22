/// A claim on an item, as seen in the Flutter UI.
class Claim {
  final String id;
  final String status; // pending | approved | rejected
  final String message;
  final bool otpVerified;

  final String? itemId;
  final String? itemTitle;

  final String? claimantId;
  final String? claimantName;

  Claim({
    required this.id,
    required this.status,
    this.message = '',
    this.otpVerified = false,
    this.itemId,
    this.itemTitle,
    this.claimantId,
    this.claimantName,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    final claimant = json['claimant'] as Map<String, dynamic>?;
    return Claim(
      id: json['id']?.toString() ?? '',
      status: (json['status'] as String?) ?? 'pending',
      message: (json['message'] as String?) ?? '',
      otpVerified: json['otpVerified'] == true,
      itemId: item?['id']?.toString(),
      itemTitle: item?['title'] as String?,
      claimantId: claimant?['id']?.toString(),
      claimantName: claimant?['name'] as String?,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}
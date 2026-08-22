import 'package:campus_lost_found/core/models/claim.dart';
import 'package:campus_lost_found/core/models/app_notification.dart';
import 'package:campus_lost_found/core/services/api_service.dart';

/// Handles the in-app claim workflow: listing claims that need a poster's
/// approval, listing a user's own claims, approving a claim, and reading
/// notifications (where the OTP is delivered).
class ClaimService {
  final ApiService apiService;

  ClaimService({required this.apiService});

  /// Claims on items that THIS user posted (i.e. claims they can approve).
  Future<List<Claim>> fetchClaimsToApprove(String ownerUserId) async {
    const query = r'''
      query ClaimsToApprove($ownerId: ID!) {
        claims(where: { item: { postedBy: { id: { equals: $ownerId } } } }) {
          id
          status
          message
          otpVerified
          item { id title }
          claimant { id name }
        }
      }
    ''';

    final result = await apiService.query(query, variables: {'ownerId': ownerUserId});
    final list = (result['claims'] as List?) ?? [];
    return list
        .map((e) => Claim.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Claims that THIS user has made themselves.
  Future<List<Claim>> fetchMyClaims(String claimantId) async {
    const query = r'''
      query MyClaims($claimantId: ID!) {
        claims(where: { claimant: { id: { equals: $claimantId } } }) {
          id
          status
          message
          otpVerified
          item { id title }
          claimant { id name }
        }
      }
    ''';

    final result = await apiService.query(query, variables: {'claimantId': claimantId});
    final list = (result['claims'] as List?) ?? [];
    return list
        .map((e) => Claim.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Approve a claim. The backend then generates the OTP and notifies the claimant.
  Future<bool> approveClaim(String claimId) async {
    const mutation = r'''
      mutation ApproveClaim($id: ID!) {
        updateClaim(where: { id: $id }, data: { status: "approved" }) {
          id
          status
        }
      }
    ''';

    final result = await apiService.mutation(mutation, variables: {'id': claimId});
    final data = result['updateClaim'] as Map<String, dynamic>?;
    return data?['status'] == 'approved';
  }

  /// Reject a claim.
  Future<bool> rejectClaim(String claimId) async {
    const mutation = r'''
      mutation RejectClaim($id: ID!) {
        updateClaim(where: { id: $id }, data: { status: "rejected" }) {
          id
          status
        }
      }
    ''';

    final result = await apiService.mutation(mutation, variables: {'id': claimId});
    final data = result['updateClaim'] as Map<String, dynamic>?;
    return data?['status'] == 'rejected';
  }

  /// Notifications for the signed-in user. The backend already filters these
  /// to the current user, so this returns only their own.
  Future<List<AppNotification>> fetchMyNotifications() async {
    const query = r'''
      query MyNotifications {
        notifications(orderBy: { createdAt: desc }) {
          id
          type
          message
          isRead
          createdAt
        }
      }
    ''';

    final result = await apiService.query(query);
    final list = (result['notifications'] as List?) ?? [];
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
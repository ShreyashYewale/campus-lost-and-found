import 'package:campus_lost_found/core/models/claim.dart';
import 'package:campus_lost_found/core/services/api_service.dart';

class ClaimService {
  final ApiService apiService;

  ClaimService({required this.apiService});

  Future<List<Claim>> fetchClaimsForItem(String itemId) async {
    const query = r'''
      query GetClaimsForItem($itemId: ID!) {
        claims(where: { item: { id: { equals: $itemId } } }, orderBy: { createdAt: desc }) {
          id
          status
          message
          createdAt
          claimant {
            id
            name
            email
          }
        }
      }
    ''';

    final result = await apiService.query(query, variables: {'itemId': itemId});
    final claims = result['claims'] as List<dynamic>? ?? const [];
    return claims.map((entry) => Claim.fromJson(entry as Map<String, dynamic>)).toList();
  }

  Future<bool> updateClaimStatus({
    required String claimId,
    required String status,
  }) async {
    const mutation = r'''
      mutation UpdateClaimStatus($id: ID!, $status: String!) {
        updateClaim(where: { id: $id }, data: { status: $status }) {
          id
          status
        }
      }
    ''';

    final result = await apiService.mutation(
      mutation,
      variables: {'id': claimId, 'status': status},
    );

    return result.containsKey('updateClaim');
  }
}

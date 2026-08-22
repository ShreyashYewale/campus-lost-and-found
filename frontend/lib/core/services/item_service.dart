import 'package:campus_lost_found/core/models/item.dart';
import 'package:campus_lost_found/core/services/api_service.dart';
 
class ItemService {
  final ApiService apiService;
 
  ItemService({required this.apiService});
 
  Future<List<Item>> fetchItems() async {
    const query = r'''
      query GetItems {
        items {
          id
          title
          description
          type
          category
          location
          status
          createdAt
          photo {
            url
          }
          postedBy {
            id
            name
            email
          }
        }
      }
    ''';
 
    final result = await apiService.query(query);
    final items = result['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Item.fromJson(item as Map<String, dynamic>)).toList();
  }
 
  Future<Item?> fetchItemById(String id) async {
    const query = r'''
      query GetItemById($id: ID!) {
        item(where: { id: $id }) {
          id
          title
          description
          type
          category
          location
          status
          createdAt
          photo {
            url
          }
          postedBy {
            id
            name
            email
          }
        }
      }
    ''';
 
    final result = await apiService.query(query, variables: {'id': id});
    final item = result['item'];
    if (item == null) return null;
    return Item.fromJson(item as Map<String, dynamic>);
  }
 
  Future<bool> createItem({
    required String title,
    required String description,
    required String type,
    required String category,
    required String location,
    required String postedById,
    String status = 'open',
    bool allowDuplicate = false,
    List<int>? photoBytes,
    String? photoFilename,
  }) async {
    const mutation = r'''
      mutation CreateItem(
        $title: String!,
        $description: String!,
        $type: String!,
        $category: String!,
        $location: String!,
        $status: String!,
        $allowDuplicate: Boolean,
        $postedBy: UserRelateToOneForCreateInput!
      ) {
        createItem(data: {
          title: $title,
          description: $description,
          type: $type,
          category: $category,
          location: $location,
          status: $status,
          allowDuplicate: $allowDuplicate,
          postedBy: $postedBy
        }) {
          id
          title
        }
      }
    ''';
 
    final variables = {
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'location': location,
      'status': status,
      'allowDuplicate': allowDuplicate,
      'postedBy': {'connect': {'id': postedById}},
    };
 
    final createResult = await apiService.mutation(mutation, variables: variables);
    final createdItem = createResult['createItem'] as Map<String, dynamic>?;
    if (createdItem == null) return false;
 
    if (photoBytes == null || photoBytes.isEmpty) {
      return true;
    }
 
    final itemId = createdItem['id']?.toString();
    if (itemId == null || itemId.isEmpty) return false;
 
    return uploadItemPhoto(
      itemId: itemId,
      photoBytes: photoBytes,
      photoFilename: photoFilename ?? 'photo.jpg',
    );
  }
 
  Future<bool> uploadItemPhoto({
    required String itemId,
    required List<int> photoBytes,
    required String photoFilename,
  }) async {
    return apiService.uploadItemPhoto(
      itemId: itemId,
      fileBytes: photoBytes,
      filename: photoFilename,
    );
  }
 
  Future<bool> createClaim({
    required String itemId,
    required String claimantId,
    String message = '',
  }) async {
    const mutation = r'''
      mutation CreateClaim(
        $item: ItemRelateToOneForCreateInput!,
        $claimant: UserRelateToOneForCreateInput!,
        $message: String
      ) {
        createClaim(data: {
          item: $item,
          claimant: $claimant,
          message: $message
        }) {
          id
          status
        }
      }
    ''';
 
    final result = await apiService.mutation(mutation, variables: {
      'item': {'connect': {'id': itemId}},
      'claimant': {'connect': {'id': claimantId}},
      'message': message,
    });
 
    return result.containsKey('createClaim');
  }
 
  /// Calls the custom backend mutation that verifies a claim's OTP.
  /// Returns a (success, message) pair so the UI can show the outcome.
  Future<({bool success, String message})> verifyClaimOtp({
    required String claimId,
    required String code,
  }) async {
    const mutation = r'''
      mutation VerifyClaimOtp($claimId: ID!, $code: String!) {
        verifyClaimOtp(claimId: $claimId, code: $code) {
          success
          message
        }
      }
    ''';
 
    final result = await apiService.mutation(mutation, variables: {
      'claimId': claimId,
      'code': code,
    });
 
    final data = result['verifyClaimOtp'] as Map<String, dynamic>?;
    if (data == null) {
      return (success: false, message: 'No response from server.');
    }
    return (
      success: data['success'] == true,
      message: (data['message'] as String?) ?? '',
    );
  }
}
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
        $postedBy: UserRelateToOneForCreateInput!,
        $photo: Upload
      ) {
        createItem(data: {
          title: $title,
          description: $description,
          type: $type,
          category: $category,
          location: $location,
          status: $status,
          postedBy: $postedBy,
          photo: { upload: $photo }
        }) {
          id
          title
          photo {
            url
          }
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
      'postedBy': {'connect': {'id': postedById}},
    };

    final Map<String, dynamic> result;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      result = await apiService.uploadMutation(
        mutation,
        variables: variables,
        fileVariableKey: 'photo',
        fileBytes: photoBytes,
        filename: photoFilename ?? 'photo.jpg',
      );
    } else {
      result = await apiService.mutation(mutation, variables: variables);
    }

    return result.containsKey('createItem');
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
}

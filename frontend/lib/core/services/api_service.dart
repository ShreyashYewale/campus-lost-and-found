import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl;
  final String apiOrigin;
  final Logger logger = Logger();

  late final http.Client _client;
  String? _sessionToken;

  ApiService({
    required this.baseUrl,
    String? apiOrigin,
  }) : apiOrigin = apiOrigin ?? _deriveOrigin(baseUrl) {
    _client = http.Client();
  }

  static String _deriveOrigin(String graphqlUrl) {
    const suffix = '/api/graphql';
    if (graphqlUrl.endsWith(suffix)) {
      return graphqlUrl.substring(0, graphqlUrl.length - suffix.length);
    }
    return graphqlUrl;
  }

  String? get sessionToken => _sessionToken;

  void setSessionToken(String? token) {
    _sessionToken = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_sessionToken != null && _sessionToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_sessionToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      logger.d('GraphQL Query: $query');

      final response = await _client
          .post(
            Uri.parse(baseUrl),
            headers: _headers(),
            body: jsonEncode({
              'query': query,
              'variables': variables ?? {},
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('errors')) {
          logger.e('GraphQL Error: ${data['errors']}');
          throw Exception(data['errors'].toString());
        }
        return data['data'] ?? {};
      } else {
        logger.e('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      logger.e('API Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> mutation(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    return query(mutation, variables: variables);
  }

  MediaType _imageMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  Future<bool> uploadItemPhoto({
    required String itemId,
    required List<int> fileBytes,
    required String filename,
  }) async {
    if (_sessionToken == null || _sessionToken!.isEmpty) {
      throw Exception('Not signed in. Please sign in before uploading a photo.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiOrigin/api/items/$itemId/photo'),
      );
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $_sessionToken';
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          fileBytes,
          filename: filename,
          contentType: _imageMediaType(filename),
        ),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout'),
      );
      final response = await http.Response.fromStream(streamed);
      final body = response.body;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      logger.e('Photo upload HTTP Error: ${response.statusCode} $body');
      throw Exception(
        body.isNotEmpty ? 'HTTP ${response.statusCode}: $body' : 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Photo upload error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadMutation(
    String mutation, {
    required Map<String, dynamic> variables,
    required String fileVariableKey,
    required List<int> fileBytes,
    required String filename,
  }) async {
    if (_sessionToken == null || _sessionToken!.isEmpty) {
      throw Exception('Not signed in. Please sign in before uploading a photo.');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Accept'] = 'application/json';
      // Required by Apollo Server CSRF protection for multipart uploads.
      request.headers['Apollo-Require-Preflight'] = 'true';
      if (_sessionToken != null && _sessionToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_sessionToken';
      }

      final uploadVariables = Map<String, dynamic>.from(variables);
      uploadVariables[fileVariableKey] = null;

      request.fields['operations'] = jsonEncode({
        'query': mutation,
        'variables': uploadVariables,
      });
      request.fields['map'] = jsonEncode({
        '0': ['variables.$fileVariableKey'],
      });
      request.files.add(
        http.MultipartFile.fromBytes(
          '0',
          fileBytes,
          filename: filename,
          contentType: _imageMediaType(filename),
        ),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Upload timeout'),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('errors')) {
          logger.e('GraphQL Upload Error: ${data['errors']}');
          throw Exception(data['errors'].toString());
        }
        return data['data'] ?? {};
      }

      logger.e('Upload HTTP Error: ${response.statusCode} ${response.body}');
      throw Exception(
        response.body.isNotEmpty
            ? 'HTTP ${response.statusCode}: ${response.body}'
            : 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Upload Error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

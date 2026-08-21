import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl;
  final Logger logger = Logger();

  late final http.Client _client;
  String? _sessionToken;

  ApiService({required this.baseUrl}) {
    _client = http.Client();
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

  Future<Map<String, dynamic>> uploadMutation(
    String mutation, {
    required Map<String, dynamic> variables,
    required String fileVariableKey,
    required List<int> fileBytes,
    required String filename,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
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
        http.MultipartFile.fromBytes('0', fileBytes, filename: filename),
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
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      logger.e('Upload Error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

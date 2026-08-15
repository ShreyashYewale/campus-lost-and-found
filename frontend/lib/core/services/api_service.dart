import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl;
  final Logger logger = Logger();
  
  late final http.Client _client;

  ApiService({required this.baseUrl}) {
    _client = http.Client();
  }

  Future<Map<String, dynamic>> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      logger.d('GraphQL Query: $query');
      
      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables ?? {},
        }),
      ).timeout(
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

  void dispose() {
    _client.close();
  }
}

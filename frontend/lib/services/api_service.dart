import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Existing method to get a Map<String, dynamic>
  Future<Map<String, dynamic>> get(String endpoint, {bool useAuth = false}) async {
    try {
      final headers = await _getHeaders(useAuth);
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response received');
        }
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<dynamic>> getAsList(String endpoint, {bool useAuth = false}) async {
    try {
      final headers = await _getHeaders(useAuth);
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          return decodedResponse;
        } else {
          throw Exception('Expected a list response, got ${decodedResponse.runtimeType}');
        }
      } else {
        throw Exception('Failed to load data: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool useAuth = false}) async {
    try {
      final headers = await _getHeaders(useAuth);
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<Map<String, String>> _getHeaders(bool useAuth) async {
    final headers = {'Content-Type': 'application/json'};
    if (useAuth) {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}

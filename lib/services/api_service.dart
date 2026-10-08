import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configurable Base URL
  // Can be set at compile time via: --dart-define=API_BASE_URL=https://your-production-domain.com/api
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  static const String _tokenKey = 'svpuat_auth_token';
  String? _authToken;

  String? get authToken => _authToken;

  // Initialize token from SharedPreferences safely
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('SharedPreferences init warning: $e');
      _authToken = null;
    }
  }

  // Save auth token safely
  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      } else {
        await prefs.remove(_tokenKey);
      }
    } catch (e) {
      debugPrint('SharedPreferences setAuthToken warning: $e');
    }
  }

  // Common Headers
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // GET Request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        final cleanParams = <String, String>{};
        queryParams.forEach((key, value) {
          if (value.isNotEmpty) cleanParams[key] = value;
        });
        if (cleanParams.isNotEmpty) {
          uri = uri.replace(queryParameters: cleanParams);
        }
      }

      final response = await http.get(uri, headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network or Server Connection Error: $e');
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network or Server Connection Error: $e');
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network or Server Connection Error: $e');
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network or Server Connection Error: $e');
    }
  }

  // Process HTTP Response
  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    } else {
      final message = jsonBody is Map && jsonBody.containsKey('message')
          ? jsonBody['message']
          : 'Server Error (${response.statusCode})';
      throw Exception(message);
    }
  }
}

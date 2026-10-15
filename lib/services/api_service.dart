import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configurable Base URL
  // Default Render Production Backend: https://svpuat-study-app.onrender.com/api
  // Can be overridden at compile time via: --dart-define=API_BASE_URL=...
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    return 'https://svpuat-study-app.onrender.com/api';
  }

  static const String _tokenKey = 'svpuat_auth_token';
  static const Duration _timeoutDuration = Duration(seconds: 90);
  String? _authToken;

  String? get authToken => _authToken;

  Future<String?> getValidAuthToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_tokenKey);
      return _authToken;
    } catch (e) {
      return null;
    }
  }

  // Initialize token from SharedPreferences safely & trigger background server wakeup
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('SharedPreferences init warning: $e');
      _authToken = null;
    }

    // Non-blocking background ping to wake up Render instance from cold sleep
    unawaited(
      http
          .get(Uri.parse('$baseUrl/colleges'))
          .timeout(const Duration(seconds: 15))
          .then((_) {})
          .catchError((_) {}),
    );
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

  String _cleanExceptionMessage(dynamic e) {
    final str = e.toString();
    if (str.contains('TimeoutException')) {
      return 'Server connection timed out. If server was sleeping, please tap login again.';
    }
    if (str.contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    return str
        .replaceAll('Exception: ', '')
        .replaceAll('TimeoutException: ', '')
        .replaceAll('SocketException: ', '');
  }

  Future<dynamic> _executeWithRetry(Future<http.Response> Function() action, {int maxRetries = 2}) async {
    int attempt = 0;
    while (attempt <= maxRetries) {
      try {
        final response = await action().timeout(_timeoutDuration, onTimeout: () {
          throw TimeoutException('Server connection timed out.');
        });
        return _processResponse(response);
      } catch (e) {
        if (e.toString().contains('HTTP ')) rethrow;
        attempt++;
        if (attempt > maxRetries) {
          throw Exception(_cleanExceptionMessage(e));
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  // GET Request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    return _executeWithRetry(() {
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
      return http.get(uri, headers: _headers);
    });
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    return _executeWithRetry(() {
      final uri = Uri.parse('$baseUrl$endpoint');
      return http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
    });
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    return _executeWithRetry(() {
      final uri = Uri.parse('$baseUrl$endpoint');
      return http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
    });
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    return _executeWithRetry(() {
      final uri = Uri.parse('$baseUrl$endpoint');
      return http.delete(uri, headers: _headers);
    });
  }

  // Process HTTP Response
  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      String text = response.body;
      if (text.contains('<pre>')) {
        final match = RegExp(r'<pre>(.*?)</pre>', dotAll: true).firstMatch(text);
        if (match != null) text = match.group(1)?.trim() ?? text;
      }
      jsonBody = {'message': text};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    } else {
      final message = jsonBody is Map && jsonBody.containsKey('message') && jsonBody['message'].toString().isNotEmpty
          ? jsonBody['message'].toString()
          : 'Server Error (${response.statusCode})';
      throw Exception('HTTP ${response.statusCode}: $message');
    }
  }
}

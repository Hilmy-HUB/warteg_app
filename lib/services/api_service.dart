import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) {
      // Gunakan 'http://10.0.2.2:8080' untuk Android Emulator
      // Gunakan 'http://192.168.17.122:8080' jika menggunakan HP Fisik (Real Device)
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static String get wsBaseUrl {
    return baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers(bool requireAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<dynamic> get(String path, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.get(url, headers: await _headers(requireAuth));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, dynamic body, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.post(
      url,
      headers: await _headers(requireAuth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, dynamic body, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.put(
      url,
      headers: await _headers(requireAuth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.delete(url, headers: await _headers(requireAuth));
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded['status'] == 'success') {
        return decoded['data'];
      }
      return decoded;
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Request failed with status: ${response.statusCode}');
    }
  }
}

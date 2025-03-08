// kullanıcı işlemleri için kullanılacak servis.

// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_models/user_register_model.dart';

class UserService {
  final String baseUrl = 'http://10.0.2.2:8080/rest/api';

  Future<Map<String, dynamic>> registerUser(UserRegisterModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/save'),
        headers: {
          'Content-Type': "application/json; charset=utf-8",
          'Accept': "application/json; charset=utf-8",
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = utf8.decode(response.bodyBytes);
        return {'success': true, 'data': jsonDecode(responseBody)};
      } else {
        // Backend'den gelen hata mesajını döndür
        String errorMessage;
        try {
          // UTF-8 encoding ile response body'sini decode et
          final responseBody = utf8.decode(response.bodyBytes);
          final errorData = jsonDecode(responseBody);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Bilinmeyen hata: ${response.statusCode}';
        } catch (e) {
          // JSON decode edilemezse doğrudan UTF-8 ile decode edilmiş response body'i kullan
          errorMessage = utf8.decode(response.bodyBytes);
        }
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Login servisi de eklenebilir
  Future<Map<String, dynamic>> loginUser(Map<String, String> loginData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {
          'Content-Type': "application/json; charset=utf-8",
          'Accept': "application/json; charset=utf-8",
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        // UTF-8 encoding ile response body'sini decode et
        final responseBody = utf8.decode(response.bodyBytes);
        return {'success': true, 'data': jsonDecode(responseBody)};
      } else {
        // Backend'den gelen hata mesajını döndür
        String errorMessage;
        try {
          // UTF-8 encoding ile response body'sini decode et
          final responseBody = utf8.decode(response.bodyBytes);
          final errorData = jsonDecode(responseBody);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Bilinmeyen hata: ${response.statusCode}';
        } catch (e) {
          // JSON decode edilemezse doğrudan UTF-8 ile decode edilmiş response body'i kullan
          errorMessage = utf8.decode(response.bodyBytes);
        }
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }
}

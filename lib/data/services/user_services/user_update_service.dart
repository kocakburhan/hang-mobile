import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/user_models/user_update_model.dart';

class UserUpdateService {
  final String baseUrl = 'http://10.0.2.2:8080/rest/api';

  Future<Map<String, dynamic>> updateUser(
    String userId,
    UserUpdateModel userUpdateData,
  ) async {
    try {
      final url = '$baseUrl/user/update/$userId';
      debugPrint('Gönderilecek URL: $url');

      // JSON içeriğini hazırlayalım ve debug için kontrol edelim
      final jsonBody = userUpdateData.toJson();
      debugPrint('Gönderilen id: $userId');
      final jsonString = jsonEncode(jsonBody);
      debugPrint('Gönderilecek veri: $jsonString');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': "application/json; charset=utf-8",
          'Accept': "application/json; charset=utf-8",
        },
        body: jsonString,
      );

      debugPrint('HTTP Yanıt Kodu: ${response.statusCode}');
      final responseBody = utf8.decode(response.bodyBytes);
      debugPrint('Sunucu yanıtı: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 2xx başarılı yanıtlar
        final responseData = jsonDecode(responseBody);

        // Yanıtta id alanı yoksa, gönderdiğimiz userId'yi ekleyelim
        if (responseData is Map<String, dynamic> &&
            !responseData.containsKey('id')) {
          responseData['id'] = userId;
          debugPrint('Sunucu yanıtına id eklendi: $userId');
        }

        return {'success': true, 'data': responseData};
      } else {
        // Hata durumunda
        String errorMessage;
        try {
          final errorData = jsonDecode(responseBody);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Bilinmeyen hata: ${response.statusCode}';
        } catch (e) {
          errorMessage =
              'Sunucu yanıtı: ${response.statusCode} - $responseBody';
        }
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      debugPrint('HTTP isteği sırasında hata: $e');
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/event_models/event_model.dart';

class EventService {
  // API URL'ini mobil cihazlar için düzeltme
  final String baseUrl = 'http://10.0.2.2:8080/rest/api';

  // Etkinlikleri getir
  // backendden gelen bilgiler için: lib\data\models\event_models\event_model.dart
  Future<List<Event>> getEvents() async {
    final url = Uri.parse('$baseUrl/event/list');
    print('Event listesi isteniyor: $url');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': "application/json; charset=utf-8",
              'Accept': "application/json; charset=utf-8",
              'Accept-Charset': 'utf-8',
              // Eğer token tabanlı yetkilendirme kullanılıyorsa:
              // 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('API Yanıt Kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = jsonDecode(response.body);
        print('Alınan etkinlik sayısı: ${eventsJson.length}');

        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        print('Event listeleme hatası: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Event listeleme exception: $e');
      // Hata durumunda boş liste dön
      return [];
    }
  }
}

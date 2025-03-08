// lib/data/services/event_services/event_create_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/event_models/event_create_model.dart';

class EventCreateService {
  // API URL'ini mobil cihazlar için düzeltme (localhost yerine IP adresi kullanma)
  // Android emülatörlerinde 10.0.2.2 host makinenizi temsil eder
  final String baseUrl = 'http://10.0.2.2:8080/rest/api';

  // Alternatif olarak gerçek IP adresiniz
  // final String baseUrl = 'http://192.168.X.X:8080/rest/api';

  // Etkinlik oluşturma
  Future<bool> createEvent(EventCreateModel event) async {
    final url = Uri.parse('$baseUrl/event/create');

    // İstek gövdesini oluştur ve logla
    final requestBody = jsonEncode(event.toJson());
    print('İstek URL: $url');
    print('İstek gövdesi: $requestBody');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': "application/json; charset=utf-8",
              'Accept': "application/json; charset=utf-8",
              'Accept-Charset': 'utf-8',
              // Eğer token tabanlı yetkilendirme kullanılıyorsa:
              // 'Authorization': 'Bearer $token',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10)); // Timeout ekleyelim

      print('API Yanıt Kodu: ${response.statusCode}');
      print('API Yanıt: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Başarılı yanıt
        return true;
      } else {
        // Hata durumu
        print('Event oluşturma hatası: ${response.body}');
        return false;
      }
    } catch (e) {
      // Daha detaylı hata bilgisi
      print('Event oluşturma exception: $e');
      if (e is SocketException) {
        print(
          'Bağlantı hatası: Sunucuya erişilemiyor veya internet bağlantınız kesik.',
        );
      } else if (e is http.ClientException) {
        print('HTTP istek hatası: ${e.message}');
      } else if (e is FormatException) {
        print('Format hatası: İstek veya yanıt formatında sorun var.');
      } else {
        print('Bilinmeyen hata: $e');
      }
      return false;
    }
  }

  // Görselleri yükleme ve URL'leri alma
  Future<List<String>> uploadImages(List<File> images) async {
    // Test amacıyla gerçek API çağrılarını atlayalım ve direkt URL dönelim
    List<String> imageUrls = [];

    if (images.isEmpty) {
      // Test için örnek resim
      imageUrls.add(
        "https://e7.pngegg.com/pngimages/55/997/png-clipart-woman-doing-yoga-pose-yoga-pilates-mats-kapotasana-yoga-physical-fitness-hand-thumbnail.png",
      );
      return imageUrls;
    }

    // Her resim için basit bir URL oluşturalım
    // Gerçek uygulamada burası gerçek bir upload işlemi yapmalı
    for (var i = 0; i < images.length; i++) {
      imageUrls.add(
        "https://example.com/images/event_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
    }

    return imageUrls;
  }
}

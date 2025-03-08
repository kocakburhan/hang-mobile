import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  String? _userId;
  Map<String, dynamic>? _userData;

  String? get userId => _userId;
  Map<String, dynamic>? get userData => _userData;

  Future<void> setUserData(Map<String, dynamic> data) async {
    _userData = data;

    // ID'yi atama yaparken daha dikkatli olalım
    if (data.containsKey('id')) {
      _userId = data['id']?.toString();
      debugPrint('UserProvider.setUserData - userId: $_userId');
    } else {
      // Eğer id yoksa, mevcut _userId değerini koruyalım
      debugPrint(
        'UserProvider.setUserData - Gelen veride id alanı yok, mevcut userId korunuyor: $_userId',
      );
    }

    // Debug için veri yapısını ekrana basalım
    debugPrint('UserProvider.setUserData - userData: ${jsonEncode(_userData)}');

    // ID ve tüm kullanıcı verilerini cihaza kaydet
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) {
      await prefs.setString('userId', _userId!);
      debugPrint(
        'UserProvider.setUserData - userId SharedPreferences\'e kaydedildi',
      );
    } else {
      debugPrint(
        'UserProvider.setUserData - UYARI: userId null olduğu için kaydedilmedi!',
      );
    }
    await prefs.setString('userData', jsonEncode(data));

    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    _userId = prefs.getString('userId');

    debugPrint('UserProvider.loadUserData - userId from prefs: $_userId');

    if (userDataString != null) {
      try {
        _userData = jsonDecode(userDataString);

        // userId boşsa userData'dan al
        if (_userId == null && _userData != null && _userData!['id'] != null) {
          _userId = _userData!['id'].toString();
          await prefs.setString('userId', _userId!);
          debugPrint(
            'UserProvider.loadUserData - userId userData\'dan alındı: $_userId',
          );
        }
      } catch (e) {
        debugPrint("Kullanıcı verilerini yüklerken hata: $e");
      }
    }

    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userData');
    _userId = null;
    _userData = null;
    notifyListeners();
  }
}

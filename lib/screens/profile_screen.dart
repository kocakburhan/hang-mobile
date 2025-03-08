// lib/screens/profile_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/layouts/main_layout.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../data/models/user_models/user_update_model.dart';
import '../data/services/user_services/user_update_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userUpdateService = UserUpdateService();
  late UserUpdateModel _userUpdate;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isPasswordObscured = true;

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _biographyController = TextEditingController();
  final _zodiacSignController = TextEditingController();
  final _risingSignController = TextEditingController();
  final _ageController = TextEditingController();

  Gender? _selectedGender;
  UserType? _selectedUserType;
  List<String> _hobbies = [];
  final _hobbyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    if (userData != null) {
      debugPrint('Kullanıcı verisi yükleniyor: $userData');

      // UserUpdateModel nesnesini oluştur
      _userUpdate = UserUpdateModel();

      // Text controller'ları doldur
      _nameController.text = userData['name'] ?? '';
      _surnameController.text = userData['surname'] ?? '';
      _nicknameController.text = userData['nickname'] ?? '';
      _phoneNumberController.text = userData['phoneNumber'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _locationController.text = userData['location'] ?? '';
      _biographyController.text = userData['biography'] ?? '';
      _zodiacSignController.text = userData['zodiacSign'] ?? '';
      _risingSignController.text = userData['risingSign'] ?? '';

      // Yaş kontrolü
      if (userData['age'] != null) {
        _ageController.text = userData['age'].toString();
      } else {
        _ageController.text = '';
      }

      // Cinsiyet seçimi
      if (userData['gender'] != null) {
        final genderStr = userData['gender'].toString();
        try {
          _selectedGender = Gender.values.firstWhere(
            (g) => g.toString().split('.').last == genderStr,
            orElse: () => Gender.OTHER,
          );
        } catch (e) {
          debugPrint('Gender dönüştürme hatası: $e');
          _selectedGender = Gender.OTHER;
        }
      }

      // Kullanıcı tipi seçimi
      if (userData['userType'] != null) {
        final userTypeStr = userData['userType'].toString();
        try {
          _selectedUserType = UserType.values.firstWhere(
            (t) => t.toString().split('.').last == userTypeStr,
            orElse: () => UserType.INDIVIDUAL,
          );
        } catch (e) {
          debugPrint('UserType dönüştürme hatası: $e');
          _selectedUserType = UserType.INDIVIDUAL;
        }
      }

      // Hobi listesini ayarla
      _hobbies = [];
      if (userData['hobbies'] != null) {
        try {
          if (userData['hobbies'] is List) {
            _hobbies = List<String>.from(userData['hobbies']);
          }
        } catch (e) {
          debugPrint('Hobi listesi dönüştürme hatası: $e');
        }
      }

      // Model nesnesini güncelle
      _userUpdate
        ..name = _nameController.text
        ..surname = _surnameController.text
        ..nickname = _nicknameController.text
        ..phoneNumber = _phoneNumberController.text
        ..email = _emailController.text
        ..location = _locationController.text
        ..biography = _biographyController.text
        ..zodiacSign = _zodiacSignController.text
        ..risingSign = _risingSignController.text
        ..gender = _selectedGender
        ..userType = _selectedUserType
        ..hobbies = List<String>.from(_hobbies);

      if (_ageController.text.isNotEmpty) {
        _userUpdate.age = int.tryParse(_ageController.text);
      }

      debugPrint(
        'Kullanıcı verileri yüklendi. Hobi sayısı: ${_hobbies.length}',
      );
    } else {
      debugPrint('Kullanıcı verisi bulunamadı');
      _userUpdate = UserUpdateModel();
      _hobbies = [];

      // Controller'ları temizle
      _nameController.text = '';
      _surnameController.text = '';
      _nicknameController.text = '';
      _phoneNumberController.text = '';
      _emailController.text = '';
      _passwordController.text = '';
      _locationController.text = '';
      _biographyController.text = '';
      _zodiacSignController.text = '';
      _risingSignController.text = '';
      _ageController.text = '';

      _selectedGender = null;
      _selectedUserType = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _nicknameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _biographyController.dispose();
    _zodiacSignController.dispose();
    _risingSignController.dispose();
    _ageController.dispose();
    _hobbyController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Formdan alınan verileri model nesnesine aktaralım
        _userUpdate
          ..name = _nameController.text
          ..surname = _surnameController.text
          ..nickname = _nicknameController.text
          ..phoneNumber = _phoneNumberController.text
          ..email = _emailController.text
          ..location = _locationController.text
          ..biography = _biographyController.text
          ..zodiacSign = _zodiacSignController.text
          ..risingSign = _risingSignController.text;

        if (_passwordController.text.isNotEmpty) {
          _userUpdate.password = _passwordController.text;
        }

        if (_ageController.text.isNotEmpty) {
          _userUpdate.age = int.tryParse(_ageController.text);
        }

        _userUpdate.gender = _selectedGender;
        _userUpdate.userType = _selectedUserType;

        // Hobi listesini açıkça atayalım
        _userUpdate.hobbies = List<String>.from(_hobbies);

        // Debug için gönderilecek veriyi kontrol edelim
        final json = _userUpdate.toJson();
        debugPrint('Gönderilecek JSON: ${jsonEncode(json)}');
        debugPrint('Hobi listesi: $_hobbies');

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Kullanıcı ID'sini bulalım, birden fazla yerden kontrol edelim
        String? userId;

        // 1. Provider'dan doğrudan almayı deneyelim
        userId = userProvider.userId;
        debugPrint('UserProvider.userId: $userId');

        // 2. Eğer null ise userData içinden almayı deneyelim
        if (userId == null || userId.isEmpty) {
          final userData = userProvider.userData;
          if (userData != null && userData['id'] != null) {
            userId = userData['id'].toString();
            debugPrint('userData[\'id\'] değeri: $userId');
          }
        }

        // 3. SharedPreferences'dan okumayı deneyelim
        if (userId == null || userId.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          userId = prefs.getString('userId');
          debugPrint('SharedPreferences\'dan userId: $userId');
        }

        // 4. Hiçbir kaynakta bulunamazsa hata fırlatmadan önce
        // yüklenmiş olan userData içindeki tüm keyleri görelim
        if (userId == null || userId.isEmpty) {
          final userData = userProvider.userData;
          if (userData != null) {
            debugPrint(
              'userData içindeki tüm keyler: ${userData.keys.toList()}',
            );
          } else {
            debugPrint('userData null!');
          }
          throw Exception(
            'Kullanıcı ID bulunamadı. Lütfen tekrar giriş yapın.',
          );
        }

        debugPrint('Kullanıcı güncelleniyor, userId: $userId');
        final result = await _userUpdateService.updateUser(userId, _userUpdate);

        if (result['success'] == true) {
          // Sunucudan dönen güncellenmiş verileri kullanıcı verilerine atayalım
          if (result['data'] != null) {
            debugPrint(
              'Güncellenmiş veriler alındı, UserProvider güncelleniyor...',
            );

            // Mevcut ID'yi koruyarak verileri güncelle
            Map<String, dynamic> updatedData = result['data'];

            // Sunucudan gelen yanıtta id yoksa, bizim userId değerimizi ekleyelim
            if (!updatedData.containsKey('id')) {
              updatedData['id'] = userId;
              debugPrint(
                'Gelen veride id yoktu, mevcut userId eklendi: $userId',
              );
            }

            await userProvider.setUserData(updatedData);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil başarıyla güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _isEditing = false;
          });

          // Profil verilerini yeniden yükleyelim
          _loadUserData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Güncelleme başarısız: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Profil güncelleme hatası: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addHobby() {
    if (_hobbyController.text.isNotEmpty) {
      final newHobby = _hobbyController.text.trim();

      if (newHobby.isEmpty) return;

      setState(() {
        _hobbies.add(newHobby);

        // UserUpdateModel'e hobiler atanıyor
        if (_userUpdate.hobbies == null) {
          _userUpdate.hobbies = [];
        }
        _userUpdate.hobbies = List<String>.from(_hobbies);

        _hobbyController.clear();
      });

      debugPrint('Hobi eklendi: "$newHobby". Güncel liste: $_hobbies');
      debugPrint('Model güncel hobi listesi: ${_userUpdate.hobbies}');
    }
  }

  void _removeHobby(int index) {
    if (index < 0 || index >= _hobbies.length) {
      debugPrint(
        'Geçersiz hobi indeksi: $index. Mevcut hobi sayısı: ${_hobbies.length}',
      );
      return;
    }

    final removedHobby = _hobbies[index];

    setState(() {
      _hobbies.removeAt(index);

      if (_userUpdate.hobbies == null) {
        _userUpdate.hobbies = [];
      } else {
        _userUpdate.hobbies = List<String>.from(_hobbies);
      }
    });

    debugPrint('Hobi silindi: "$removedHobby". Güncel liste: $_hobbies');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    // UserProvider'dan kullanıcı verilerini temizle
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.clearUserData();

    // Giriş ekranına yönlendir
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3, // Profilin sekmesi aktif
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profil Başlığı ve Düzenleme Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isEditing)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Düzenle'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Profil Resmi
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage:
                                _userUpdate.profilePicture != null
                                    ? NetworkImage(_userUpdate.profilePicture!)
                                    : null,
                            child:
                                _userUpdate.profilePicture == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Color(0xFF757575),
                                    )
                                    : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Profil resmi değiştirme kodları buraya gelecek
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Profil resmi değiştirme özelliği yakında eklenecek',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kullanıcı bilgileri
                    _isEditing ? _buildEditForm() : _buildProfileInfo(),

                    const SizedBox(height: 32),

                    // Çıkış Yap Butonu
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Çıkış Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileInfo() {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoCard(
          'Ad Soyad',
          '${_nameController.text} ${_surnameController.text}',
        ),
        _infoCard('Kullanıcı Adı', _nicknameController.text),
        _infoCard('E-posta', _emailController.text),
        _infoCard('Telefon', _phoneNumberController.text),
        _infoCard('Konum', _locationController.text),
        _infoCard('Yaş', _ageController.text),
        _infoCard(
          'Cinsiyet',
          _selectedGender != null
              ? _selectedGender.toString().split('.').last
              : '',
        ),
        _infoCard('Biyografi', _biographyController.text),
        _infoCard('Burç', _zodiacSignController.text),
        _infoCard('Yükselen', _risingSignController.text),
        _infoCard(
          'Kullanıcı Tipi',
          _selectedUserType != null
              ? _selectedUserType.toString().split('.').last
              : '',
        ),

        const SizedBox(height: 8),
        const Text(
          'Hobiler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: _hobbies.map((hobby) => Chip(label: Text(hobby))).toList(),
        ),

        const SizedBox(height: 8),
        const Text(
          'Takipçi/Takip Bilgileri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        userData?['followerCount']?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Takipçi'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        userData?['followingCount']?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Takip'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Temel bilgiler
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Ad'),
            validator: (value) {
              if (_isEditing && (value == null || value.isEmpty)) {
                return 'Lütfen adınızı girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _surnameController,
            decoration: const InputDecoration(labelText: 'Soyad'),
            validator: (value) {
              if (_isEditing && (value == null || value.isEmpty)) {
                return 'Lütfen soyadınızı girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
            validator: (value) {
              if (_isEditing && (value == null || value.isEmpty)) {
                return 'Lütfen kullanıcı adınızı girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(labelText: 'Telefon Numarası'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-posta'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (_isEditing && (value == null || value.isEmpty)) {
                return 'Lütfen e-posta adresinizi girin';
              } else if (_isEditing &&
                  !RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Şifre',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            obscureText: _isPasswordObscured,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 6) {
                return 'Şifre en az 6 karakter olmalıdır';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Konum'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Yaş'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null) {
                  return 'Geçerli bir yaş giriniz';
                } else if (age < 18 || age > 120) {
                  return 'Yaş 18-120 aralığında olmalıdır';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Cinsiyet seçimi
          DropdownButtonFormField<Gender>(
            value: _selectedGender,
            decoration: const InputDecoration(labelText: 'Cinsiyet'),
            items:
                Gender.values.map((gender) {
                  String displayText;
                  switch (gender) {
                    case Gender.MALE:
                      displayText = 'Erkek';
                      break;
                    case Gender.FEMALE:
                      displayText = 'Kadın';
                      break;
                    case Gender.OTHER:
                      displayText = 'Diğer';
                      break;
                  }

                  return DropdownMenuItem<Gender>(
                    value: gender,
                    child: Text(displayText),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Kullanıcı tipi seçimi
          DropdownButtonFormField<UserType>(
            value: _selectedUserType,
            decoration: const InputDecoration(labelText: 'Kullanıcı Tipi'),
            items:
                UserType.values.map((userType) {
                  String displayText;
                  switch (userType) {
                    case UserType.INDIVIDUAL:
                      displayText = 'Bireysel';
                      break;
                    case UserType.COMPANY:
                      displayText = 'Şirket';
                      break;
                  }

                  return DropdownMenuItem<UserType>(
                    value: userType,
                    child: Text(displayText),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUserType = value;
              });
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _biographyController,
            decoration: const InputDecoration(labelText: 'Biyografi'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _zodiacSignController,
            decoration: const InputDecoration(labelText: 'Burç'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _risingSignController,
            decoration: const InputDecoration(labelText: 'Yükselen'),
          ),
          const SizedBox(height: 20),

          // Hobiler bölümü
          const Text(
            'Hobiler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Hobi ekleme formu
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hobbyController,
                  decoration: const InputDecoration(hintText: 'Yeni hobi ekle'),
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addHobby();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addHobby, child: const Text('Ekle')),
            ],
          ),
          const SizedBox(height: 12),

          // Hobi listeleme ve silme
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_hobbies.length, (index) {
              return Chip(
                label: Text(_hobbies[index]),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeHobby(index),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Kaydet ve İptal butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadUserData(); // Değişiklikleri geri al
                    });
                  },
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// lib/screens/event_create_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/layouts/main_layout.dart';
import '../data/models/event_models/event_create_model.dart';
import '../data/services/event_services/event_create_service.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventCreateService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  final EventCreateModel _event = EventCreateModel(
    name: '',
    descriptionText: '',
    location: '',
    startDate: DateTime.now().add(const Duration(days: 1)),
    endDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
    descriptionImages: [],
    eventType: 'INDIVIDUAL_EVENT',
    isBoostedEvent: false,
  );

  List<File> _selectedImages = [];

  // Event tipleri
  final List<Map<String, dynamic>> _eventTypes = [
    {'value': 'INDIVIDUAL_EVENT', 'label': 'Bireysel Etkinlik'},
    {'value': 'COMMUNITY_EVENT', 'label': 'Topluluk Etkinliği'},
    {'value': 'BUSINESS_EVENT', 'label': 'İş Etkinliği'},
  ];

  // Boost seçenekleri
  final List<Map<String, dynamic>> _boostOptions = [
    {'value': true, 'label': 'Evet'},
    {'value': false, 'label': 'Hayır'},
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Etkinlik oluştur sekmesi aktif
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Yeni Etkinlik Oluştur',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Event İsmi
              _buildTextField(
                label: 'Etkinlik Adı',
                hint: 'Örn: Yoga Seansı',
                icon: Icons.event,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Etkinlik adı boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) => _event.name = value!,
              ),
              const SizedBox(height: 20),

              // Event Açıklaması
              _buildTextField(
                label: 'Etkinlik Açıklaması',
                hint: 'Etkinliğiniz hakkında detaylı bilgi verin',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) => _event.descriptionText = value!,
              ),
              const SizedBox(height: 20),

              // Event Lokasyonu
              _buildTextField(
                label: 'Etkinlik Konumu',
                hint: 'Örn: Sahil Parkı',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konum boş bırakılamaz';
                  }
                  return null;
                },
                onSaved: (value) => _event.location = value!,
              ),
              const SizedBox(height: 20),

              // Başlama Zamanı
              _buildDateTimePicker(
                label: 'Başlama Zamanı',
                initialDate: _event.startDate,
                icon: Icons.calendar_today,
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _event.startDate = dateTime;
                    // Bitiş tarihini başlangıç tarihinin 2 saat sonrasına ayarla
                    if (_event.endDate.isBefore(_event.startDate)) {
                      _event.endDate = _event.startDate.add(
                        const Duration(hours: 2),
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Bitiş Zamanı
              _buildDateTimePicker(
                label: 'Bitiş Zamanı',
                initialDate: _event.endDate,
                icon: Icons.calendar_today,
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _event.endDate = dateTime;
                  });
                },
                validator: () {
                  if (_event.endDate.isBefore(_event.startDate)) {
                    return 'Bitiş zamanı başlama zamanından önce olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Resim Ekleme
              _buildImageUploadSection(),
              const SizedBox(height: 30),

              // Event Tipi
              _buildDropdown(
                label: 'Etkinlik Türü',
                options: _eventTypes,
                value: _event.eventType,
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _event.eventType = value as String;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Boost Seçeneği
              _buildDropdown(
                label: 'Etkinliği Öne Çıkar',
                hint:
                    'Etkinliğiniz ana sayfada ve aramalarda öne çıkarılsın mı?',
                options: _boostOptions,
                value: _event.isBoostedEvent,
                icon: Icons.rocket_launch,
                onChanged: (value) {
                  setState(() {
                    _event.isBoostedEvent = value as bool;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/events');
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('İptal'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check),
                      label: const Text('Oluştur'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime initialDate,
    required IconData icon,
    required Function(DateTime) onDateTimeChanged,
    String? Function()? validator,
  }) {
    final formattedDate = DateFormat('dd.MM.yyyy - HH:mm').format(initialDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(initialDate, onDateTimeChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey),
                const SizedBox(width: 10),
                Text(formattedDate),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (validator != null && validator() != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              validator()!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDateTime(
    DateTime initialDate,
    Function(DateTime) onDateTimeChanged,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateTimeChanged(newDateTime);
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    String? hint,
    required List<Map<String, dynamic>> options,
    required dynamic value,
    required IconData icon,
    required void Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              hint,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text("Seçiniz"),
                ],
              ),
              style: const TextStyle(color: Colors.black87),
              onChanged: onChanged,
              items:
                  options.map<DropdownMenuItem<dynamic>>((
                    Map<String, dynamic> option,
                  ) {
                    return DropdownMenuItem<dynamic>(
                      value: option['value'],
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(option['label']),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etkinlik Görselleri',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Görsel Ekle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Center(
                  child: Text(
                    'Henüz görsel eklenmedi',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _submitForm() async {
    if (_event.endDate.isBefore(_event.startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitiş zamanı başlama zamanından önce olamaz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Seçilen görselleri URL'lere dönüştür
        _event.descriptionImages = await _eventService.uploadImages(
          _selectedImages,
        );

        // Hangi verilerle API çağrısı yapılacağını görmek için log
        print('API\'ye gönderilecek veri:');
        print(_event.toJson());

        // API'ye evenç oluşturma isteği gönderiyoruz
        final success = await _eventService.createEvent(_event);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Etkinlik başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
            ),
          );

          // Ana sayfaya yönlendir
          Navigator.pushReplacementNamed(context, '/events');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Etkinlik oluşturulurken bir hata oluştu. Konsol çıktısını kontrol edin.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

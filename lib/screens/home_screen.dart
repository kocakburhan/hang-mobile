// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/layouts/main_layout.dart';
import '../data/models/event_models/event_model.dart';
import '../data/services/event_services/event_service.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final events = await _eventService.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Etkinlikler yüklenirken hata oluştu: $e');
    }
  }

  void _handleSwipe(int index, DismissDirection direction) {
    // Mevcut kartı kaldır
    final removedEvent = _events[index];
    setState(() {
      _events.removeAt(index);
    });

    // Kullanıcı geri bildirimini göster
    final message =
        direction == DismissDirection.startToEnd
            ? 'Etkinliğe katılımcı olarak eklendiniz!'
            : 'Katılımcı olmayı reddettiniz.';

    final backgroundColor =
        direction == DismissDirection.startToEnd ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? _buildErrorView()
              : _events.isEmpty
              ? _buildEmptyView()
              : _buildEventCards(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Etkinlikler yüklenirken bir hata oluştu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEvents,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Şu an için katılabileceğiniz bir etkinlik bulunmamaktadır',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Yeni etkinlikler eklendiğinde burada görünecektir',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Katılabileceğiniz Etkinlikler',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Katılmak için sağa, reddetmek için sola kaydırın',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_events[index].id.toString()),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) => _handleSwipe(index, direction),
                  background: _buildSwipeBackground(true),
                  secondaryBackground: _buildSwipeBackground(false),
                  child: _buildEventCard(_events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(bool accept) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: accept ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: accept ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        accept ? Icons.check_circle : Icons.cancel,
        color: accept ? Colors.green : Colors.red,
        size: 32.0,
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    // Rastgele renk tonu seçimi
    final hue = (math.Random().nextDouble() * 360);
    final color = HSLColor.fromAHSL(0.2, hue, 0.7, 0.9).toColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Etkinlik görsel alanı
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: color,
                  image:
                      event.descriptionImages.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(event.descriptionImages[0]),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child: Stack(
                  children: [
                    if (event.boostedEvent)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Öne Çıkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Etkinlik detay alanı
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (event.startDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(event.startDate!)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Text(
                      event.descriptionText,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swipe, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      'Karar vermek için kaydırın',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

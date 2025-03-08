// lib/widgets/layout/main_layout.dart
import 'package:flutter/material.dart';
import 'custom_top_bar.dart';
import 'custom_bottom_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onTabTapped(int index) {
    // Seçilen sekmeye göre ekran değiştirme
    switch (index) {
      case 0: // Etkinlikler
        if (widget.currentIndex != 0) {
          Navigator.pushReplacementNamed(context, '/events');
        }
        break;
      case 1: // Arama
        if (widget.currentIndex != 1) {
          Navigator.pushReplacementNamed(context, '/search');
        }
        break;
      case 2: // Etkinlik Oluştur
        if (widget.currentIndex != 2) {
          Navigator.pushReplacementNamed(context, '/create-event');
        }
        break;
      case 3: // Profil
        if (widget.currentIndex != 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(),
      body: widget.child,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: widget.currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

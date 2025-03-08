// lib/widgets/layouts/custom_top_bar.dart
import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: const Text(
        'HANG',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
          fontSize: 24.0,
          letterSpacing: 1.5,
          color: Color.fromARGB(255, 27, 82, 153),
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Color(0x22000000),
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
      actions: [
        // Bildirim butonu
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF444444),
              size: 26,
            ),
            onPressed: () {
              // Bildirim ekranına yönlendirme
            },
          ),
        ),
        // DM butonu
        Container(
          margin: const EdgeInsets.only(left: 4, right: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.chat_outlined,
              color: Color(0xFF444444),
              size: 24,
            ),
            onPressed: () {
              // DM ekranına yönlendirme
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

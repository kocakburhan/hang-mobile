// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_create_screen.dart';
import 'screens/profile_screen.dart'; // ProfileScreen eklendi
import 'package:shared_preferences/shared_preferences.dart';
import "providers/user_provider.dart";

void main() async {
  // SharedPreferences'i kullanabilmek için Flutter widget binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Kullanıcının giriş durumunu kontrol et
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // UserProvider'ı oluştur
  final userProvider = UserProvider();

  // Eğer kullanıcı giriş yapmışsa, verilerini yükle
  if (isLoggedIn) {
    await userProvider.loadUserData();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        // diğer provider'lar...
      ],
      child: MyApp(isLoggedIn: isLoggedIn), // Sabitleme kaldırıldı
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hang app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: isLoggedIn ? '/events' : '/login',
      routes: {
        '/': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/events': (context) => const HomeScreen(),
        '/create-event': (context) => const EventCreateScreen(),
        '/profile':
            (context) => const ProfileScreen(), // ProfileScreen rotası eklendi
        // Diğer route'lar
      },
    );
  }
}

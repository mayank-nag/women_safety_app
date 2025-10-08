import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_selection_screen.dart';
import 'home_screen.dart';
import 'chatbot/chatbot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('messages');
  await Hive.openBox('emergency_contacts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Women's Safety App",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      home: const UserSelectionScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}

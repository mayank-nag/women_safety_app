import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'user_selection_screen.dart';
import 'home_screen.dart';
import 'companion.dart';
import 'profile_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive and open boxes
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
      title: "Women's Safety App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RootScreen(),
      routes: {
        '/user-selection': (context) => const UserSelectionScreen(),
      },
    );
  }
}

/// 🔹 RootScreen handles first-time role selection + profile + dashboard navigation
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? role;
  bool profileComplete = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('role');
    final name = prefs.getString('name');
    final phone = prefs.getString('phone');

    setState(() {
      role = savedRole;
      profileComplete = (name != null && phone != null);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Case 1: No role selected yet
    if (role == null) {
      return const UserSelectionScreen();
    }

    // Case 2: Role selected but no profile yet
    if (!profileComplete) {
      return ProfileFormScreen(role: role!);
    }

    // Case 3: Everything set up → go to role-based screen
    if (role == 'user') {
      return HomeScreen(role: 'user');
    } else {
      return const CompanionScreen();
    }
  }
}

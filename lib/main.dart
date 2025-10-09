import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'user_selection_screen.dart';
import 'profile_form_screen.dart';
import 'home_screen.dart';
import 'companion.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & Hive
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const RootScreen(),
      routes: {
        '/user-selection': (context) => const UserSelectionScreen(),
      },
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  String? role;
  String? name;
  String? phone;
  bool profileComplete = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('role');
    final savedName = prefs.getString('name');
    final savedPhone = prefs.getString('phone');

    setState(() {
      role = savedRole;
      name = savedName;
      phone = savedPhone;
      profileComplete = savedName != null && savedPhone != null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (role == null) return const UserSelectionScreen();
    if (!profileComplete) return ProfileFormScreen(role: role!);

    if (role == 'user') {
      return HomeScreen(role: 'user');
    } else {
      // Companion: pass companionId and linked main user ID
      final mainUserId = 'user_917783039938'; // Replace dynamically if QR scan is used
      return CompanionRoot(
        companionId: phone!,
        mainUserId: mainUserId,
      );
    }
  }
}

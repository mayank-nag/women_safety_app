// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location.dart';
import 'message.dart';
import 'emergency.dart';
import 'sos.dart';
import 'profile.dart';
import 'chatbot/chatbot.dart';

class HomeScreen extends StatefulWidget {
  final String role; // 'user' or 'companion'
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "";
  String phone = "";
  String address = "";
  String parentName = "";
  String parentPhone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "";
      phone = prefs.getString('phone') ?? "";
      address = prefs.getString('address') ?? "";
      parentName = prefs.getString('parentName') ?? "";
      parentPhone = prefs.getString('parentPhone') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == 'user';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Women's Safety App"),
        centerTitle: true,
        backgroundColor: isUser ? Colors.pinkAccent : Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    role: widget.role,
                    name: name,
                    phone: phone,
                    address: address,
                    parentName: parentName,
                    parentPhone: parentPhone,
                    profilePicUrl: null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // SOS Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(60),
                  shadowColor: Colors.redAccent,
                  elevation: 8,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SosScreen()),
                  );
                },
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickButton(
                    context,
                    Icons.phone,
                    "Call 112",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    ),
                  ),
                  _buildQuickButton(
                    context,
                    Icons.location_on,
                    "Share Location",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LocationScreen()),
                    ),
                  ),
                  _buildQuickButton(
                    context,
                    Icons.message,
                    "Messages",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MessageScreen()),
                    ),
                  ),
                  _buildQuickButton(
                    context,
                    Icons.chat_bubble_outline,
                    "Chatbot",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildQuickButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.pinkAccent),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

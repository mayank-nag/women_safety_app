// lib/companion_root.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'companion_location.dart';
import 'companion_chat.dart';
import 'profile.dart';

class CompanionRoot extends StatefulWidget {
  final String companionId; // Companion's phone or ID
  final String mainUserId; // Linked main user's phone or ID

  const CompanionRoot({
    super.key,
    required this.companionId,
    required this.mainUserId,
  });

  @override
  State<CompanionRoot> createState() => _CompanionRootState();
}

class _CompanionRootState extends State<CompanionRoot> {
  int _selectedIndex = 0;

  // Profile info
  String role = 'companion';
  String name = '';
  String phone = '';
  String address = '';
  String parentName = '';
  String parentPhone = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? 'companion';
      name = prefs.getString('name') ?? 'Companion';
      phone = prefs.getString('phone') ?? '';
      address = prefs.getString('address') ?? '';
      parentName = prefs.getString('parentName') ?? '';
      parentPhone = prefs.getString('parentPhone') ?? '';
    });
  }

  void _showQrCode() {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not found!")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SimpleQrScreen(phone: phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      CompanionLocationScreen(
        companionId: widget.companionId,
        userId: widget.mainUserId,
      ),
      CompanionChatScreen(
        mainUserId: widget.mainUserId,
        companionId: widget.companionId,
      ),
      ProfileScreen(
        role: role,
        name: name,
        phone: phone,
        address: address,
        parentName: parentName,
        parentPhone: parentPhone,
      ),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      appBar: AppBar(
        title: const Text('Companion Mode'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: _showQrCode),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class SimpleQrScreen extends StatelessWidget {
  final String phone;

  const SimpleQrScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    // generate a Firebase-consistent ID
    final companionId = "companion_${phone.replaceAll(RegExp(r'\\D'), '')}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: companionId, // ✅ the new correct ID format
              size: 220,
              version: QrVersions.auto,
              gapless: false,
            ),
            const SizedBox(height: 20),
            Text(
              "Scan to link Companion:\n$companionId",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

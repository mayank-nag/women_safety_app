// lib/companion_root.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'companion_location.dart';
import 'companion_chat.dart';
import 'profile.dart';

class CompanionRoot extends StatefulWidget {
  final String companionId; // e.g., companion_33333
  final String mainUserId; // optional (used after linking)

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

  // Chat linkage
  String? linkedUserId;
  bool _isLoadingChat = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _fetchLinkedUser();
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

  /// ✅ fetch linked user dynamically from Firebase
  Future<void> _fetchLinkedUser() async {
    setState(() => _isLoadingChat = true);

    final prefs = await SharedPreferences.getInstance();
    final companionId = prefs.getString('userId') ?? "";

    if (companionId.isEmpty) {
      print("ERROR → companion ID missing in SharedPreferences");
      setState(() => _isLoadingChat = false);
      return;
    }

    try {
      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db.child("users/$companionId/linkedUser").get();

      if (!snapshot.exists || snapshot.value == null) {
        print("DEBUG → no linked user yet for $companionId");
        setState(() {
          linkedUserId = null;
          _isLoadingChat = false;
        });
        return;
      }

      linkedUserId = snapshot.value.toString();
      print("DEBUG → companion linked with user: $linkedUserId");
    } catch (e) {
      print("ERROR (companion_root) → $e");
    } finally {
      setState(() => _isLoadingChat = false);
    }
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
        userId: linkedUserId ?? widget.mainUserId,
      ),

      // ✅ Chat tab — shows loading or chat screen directly
      _isLoadingChat
          ? const Center(child: CircularProgressIndicator())
          : linkedUserId == null
              ? const Center(
                  child: Text(
                    "No linked user yet.\nAsk the user to scan your QR code.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                )
              : CompanionChatScreen(
                  mainUserId: linkedUserId!,
                  companionId: widget.companionId,
                ),

      // Profile tab
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
        onTap: (index) async {
          setState(() => _selectedIndex = index);

          // 🔄 Refresh linked user when switching to chat tab
          if (index == 1) {
            await _fetchLinkedUser();
          }
        },
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
    // ✅ generate correct Firebase ID
    final companionId = "companion_${phone.replaceAll(RegExp(r'\D'), '')}";

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
              data: companionId,
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

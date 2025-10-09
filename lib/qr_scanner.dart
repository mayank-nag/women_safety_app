// lib/qr_scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final db = FirebaseDatabase.instance.ref();
  String? mainUserId;

  @override
  void initState() {
    super.initState();
    _loadMainUserId();
  }

  Future<void> _loadMainUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mainUserId = prefs.getString('userId');
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final companionId = barcode.rawValue;
    if (companionId == null || mainUserId == null) return;

    // Check if companion exists
    final snapshot = await db.child('users/$companionId').get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Companion not found in database!")),
      );
      return;
    }

    // Link mainUser -> companion
    await db.child('users/$mainUserId/companion').set(companionId);

    // Link companion -> mainUser
    await db.child('users/$companionId/mainUser').set(mainUserId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Companion linked successfully!")),
    );

    // Close scanner
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (mainUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Companion QR")),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}

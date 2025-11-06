// lib/qr_scanner.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';

class QRScannerScreen extends StatefulWidget {
  final String currentUserPhone;

  const QRScannerScreen({super.key, required this.currentUserPhone});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool _scanned = false;

  /// Handles scanned QR codes (links user ↔ companion dynamically)
  Future<void> _handleQRCode(String code) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    final companionId = code.trim(); // Expected format: "companion_<phone>"
    final currentUserId = "user_${widget.currentUserPhone.replaceAll(RegExp(r'\\D'), '')}";

    if (!companionId.startsWith("companion_")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR code. Please scan a valid Companion QR.")),
      );
      setState(() => _scanned = false);
      return;
    }

    try {
      // 🔹 Link both user and companion in Realtime DB
      await _db.child('users/$currentUserId').update({
        'linkedCompanion': companionId,
      });

      await _db.child('users/$companionId').update({
        'linkedUser': currentUserId,
      });

      if (!mounted) return;

      // ✅ Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Link Successful!"),
          content: Text(
            "You are now linked with $companionId.\nYou can now chat and share your live location.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // return to previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error linking: $e")),
        );
      }
    }

    // reset scanned flag after short delay to avoid multiple triggers
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _scanned = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  _handleQRCode(code);
                  break;
                }
              }
            },
          ),
          if (_scanned)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                width: double.infinity,
                child: const Text(
                  'Scanning...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

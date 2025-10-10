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

  void _handleQRCode(String code) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    // Prototype: always link to this companion
    const companionPhone = '7297017927';

    try {
      // Update backend
      await _db.child('users/${widget.currentUserPhone}').update({
        'linkedCompanion': companionPhone,
      });
      await _db.child('users/$companionPhone').update({
        'linkedUser': widget.currentUserPhone,
      });

      // Success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success!"),
            content: const Text("User and Companion linked successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error linking: $e")),
        );
      }
    }

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
      appBar: AppBar(title: const Text("QR Scanner")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) _handleQRCode(code); // pretend this is companion QR
              }
            },
          ),
          if (_scanned)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: const Text(
                  'Scanning...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

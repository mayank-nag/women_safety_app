import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS")),
      body: const Center(
        child: Text("SOS triggered! (Here we will send location, SMS, WhatsApp, camera footage)"),
      ),
    );
  }
}
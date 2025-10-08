// lib/companion.dart

import 'package:flutter/material.dart';

class CompanionScreen extends StatelessWidget {
  const CompanionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Mode'),
        backgroundColor: Colors.blueGrey,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart, size: 80, color: Colors.blueGrey),
            SizedBox(height: 20),
            Text(
              'Emergency Contact Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'This is where the companion functionality will live. You can add features like:\n\n1. Displaying the primary user\'s last known location.\n2. Receiving real-time distress alerts.\n3. A button to call the user.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
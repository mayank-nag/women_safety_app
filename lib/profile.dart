import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text("User Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Name: Demo User"),
            Text("Phone: +91-XXXXXXXXXX"),
            Text("Emergency Contact: Not Set"),
            SizedBox(height: 20),
            Text("Camera & Storage permissions will be here."),
          ],
        ),
      ),
    );
  }
}
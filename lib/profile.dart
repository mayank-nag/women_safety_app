// lib/profile.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String role; // 'user' or 'companion'
  final String name;
  final String phone;
  final String address;
  final String parentName;
  final String parentPhone;
  final String? profilePicUrl; // optional

  const ProfileScreen({
    super.key,
    required this.role,
    required this.name,
    required this.phone,
    required this.address,
    required this.parentName,
    required this.parentPhone,
    this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: role == 'user' ? Colors.pinkAccent : Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
              child: profilePicUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            _buildInfoRow("Name", name),
            const SizedBox(height: 12),
            _buildInfoRow("Mobile Number", phone),
            const SizedBox(height: 12),
            _buildInfoRow("Address", address),
            const SizedBox(height: 12),
            _buildInfoRow("Parent/Guardian Name", parentName),
            const SizedBox(height: 12),
            _buildInfoRow("Parent/Guardian Number", parentPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

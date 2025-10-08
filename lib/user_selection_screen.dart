// lib/user_selection_screen.dart
import 'package:flutter/material.dart';
import 'profile_form_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Women Safety App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD81B60),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your role to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 50),

              _buildRoleButton(
                context,
                icon: Icons.female,
                label: "I am a Woman",
                colors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
                role: 'user',
              ),
              const SizedBox(height: 30),
              _buildRoleButton(
                context,
                icon: Icons.people_alt,
                label: "I am a Companion",
                colors: [Color(0xFFF8BBD0), Color(0xFFD81B60)],
                role: 'companion',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context,
      {required IconData icon,
      required String label,
      required List<Color> colors,
      required String role}) {
    return InkWell(
      onTap: () {
        // Navigate to Profile Form to enter real details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileFormScreen(role: role),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

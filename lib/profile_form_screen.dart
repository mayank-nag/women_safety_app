import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Import RootScreen to redirect back

class ProfileFormScreen extends StatefulWidget {
  final String role; // 'user' or 'companion'
  const ProfileFormScreen({super.key, required this.role});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', widget.role);
    await prefs.setString('name', _nameController.text);
    await prefs.setString('phone', _phoneController.text);
    if (widget.role == 'user') {
      await prefs.setString('address', _addressController.text);
      await prefs.setString('parentName', _parentNameController.text);
      await prefs.setString('parentPhone', _parentPhoneController.text);
    }

    if (!mounted) return;

    // ✅ Return to RootScreen instead of pushing multiple routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RootScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == 'user';

    return Scaffold(
      appBar: AppBar(
        title: Text(isUser ? "Enter Your Details" : "Companion Details"),
        backgroundColor: isUser ? Colors.pinkAccent : Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 16),

              // User-only fields
              if (isUser)
                Column(
                  children: [
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Enter address" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: const InputDecoration(
                        labelText: "Parent/Guardian Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? "Enter parent name" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentPhoneController,
                      decoration: const InputDecoration(
                        labelText: "Parent/Guardian Phone",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v!.isEmpty ? "Enter parent phone" : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isUser ? Colors.pinkAccent : Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveProfile,
                child: const Text(
                  "Save & Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

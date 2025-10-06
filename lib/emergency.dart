import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late Box _emergencyBox;

  @override
  void initState() {
    super.initState();
    _emergencyBox = Hive.box('emergency_contacts');
  }

  Future<void> _pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      try {
        final Contact? contact = await FlutterContacts.openExternalPick();
        if (contact != null && contact.phones.isNotEmpty) {
          // Save contact to Hive
          _emergencyBox.add({
            'name': contact.displayName,
            'phone': contact.phones.first.number,
          });
          setState(() {});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick contact: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts permission denied")),
      );
    }
  }

  void _deleteContact(int index) {
    _emergencyBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _pickContact,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _emergencyBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text("No emergency contacts added yet.\nTap + to add from contacts."),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final contact = box.getAt(index) as Map;
              return ListTile(
                title: Text(contact['name'] ?? ''),
                subtitle: Text(contact['phone'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteContact(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

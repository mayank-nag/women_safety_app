import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:another_telephony/telephony.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final Telephony telephony = Telephony.instance;

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Box _messageBox;
  late Box _emergencyBox;

  @override
  void initState() {
    super.initState();
    _messageBox = Hive.box('messages');
    _emergencyBox = Hive.box('emergency_contacts');
    _askSmsPermission();
  }

  Future<void> _askSmsPermission() async {
    bool? granted = await telephony.requestPhoneAndSmsPermissions;
    if (granted != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SMS permission not granted")),
      );
    }
  }

  Future<void> _addNewContact() async {
    if (await FlutterContacts.requestPermission()) {
      final Contact? contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        final name = contact.displayName;
        final phone = contact.phones.first.number;

        _emergencyBox.add({'name': name, 'phone': phone});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$name added successfully!")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to access contacts")),
        );
      }
    }
  }

  void _openChat(String name, String phone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(contactName: name, phoneNumber: phone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(
                  emergencyBox: _emergencyBox,
                  onTap: _openChat,
                ),
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _emergencyBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No contacts yet.\nTap + to add from your contact list.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final contacts = List.generate(box.length, (i) => box.getAt(i) as Map);

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(contact['name'] ?? 'Unknown'),
                subtitle: Text(contact['phone'] ?? ''),
                onTap: () => _openChat(contact['name'] ?? '', contact['phone'] ?? ''),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _addNewContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final Box emergencyBox;
  final Function(String, String) onTap;

  ContactSearchDelegate({required this.emergencyBox, required this.onTap});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildContactList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildContactList();

  Widget _buildContactList() {
    final filtered = List.generate(emergencyBox.length, (i) => emergencyBox.getAt(i) as Map)
        .where((c) => (c['name']?.toLowerCase() ?? '').contains(query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) return const Center(child: Text("No matching contacts found"));

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final contact = filtered[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(contact['name'] ?? 'Unknown'),
          subtitle: Text(contact['phone'] ?? ''),
          onTap: () {
            onTap(contact['name'] ?? '', contact['phone'] ?? '');
            close(context, null);
          },
        );
      },
    );
  }
}

class ChatPage extends StatefulWidget {
  final String contactName;
  final String phoneNumber;

  const ChatPage({super.key, required this.contactName, required this.phoneNumber});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late Box _messageBox;

  @override
  void initState() {
    super.initState();
    _messageBox = Hive.box('messages');
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final cleanedNumber = widget.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final waUri = Uri.parse("https://wa.me/$cleanedNumber?text=${Uri.encodeComponent(text)}");

    try {
      // ✅ Always try WhatsApp first
      final canOpen = await canLaunchUrl(waUri);

      if (canOpen) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening WhatsApp...")),
        );
      } else {
        // WhatsApp cannot open
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp not available, sending SMS instead...")),
        );

        final connectivity = await Connectivity().checkConnectivity();
        final hasInternet = connectivity == ConnectivityResult.mobile || connectivity == ConnectivityResult.wifi;

        if (!hasInternet) {
          await telephony.sendSms(to: cleanedNumber, message: text, isMultipart: true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No internet — sent via SMS")),
          );
        } else {
          await telephony.sendSms(to: cleanedNumber, message: text, isMultipart: true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fallback to SMS complete")),
          );
        }
      }

      // 💾 Save the message locally
      await _messageBox.add({
        'contact': widget.contactName,
        'phone': widget.phoneNumber,
        'text': text,
        'time': DateTime.now().toString().substring(0, 16),
      });

      _controller.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messageBox.values.where((msg) => msg['phone'] == widget.phoneNumber).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.contactName)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg['text']),
                              const SizedBox(height: 4),
                              Text(
                                msg['time'],
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

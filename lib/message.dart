// lib/message.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_telephony/telephony.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
    _initHive();
    _askSmsPermission();
  }

  Future<void> _initHive() async {
    _messageBox = await Hive.openBox('messages');
    _emergencyBox = await Hive.openBox('emergency_contacts');
    setState(() {});
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
    if (!Hive.isBoxOpen('emergency_contacts')) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                onTap: () =>
                    _openChat(contact['name'] ?? '', contact['phone'] ?? ''),
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
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
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

    // Save locally
    await _messageBox.add({
      'contact': widget.contactName,
      'phone': widget.phoneNumber,
      'text': text,
      'time': DateTime.now().toString().substring(0, 16),
    });

    // Send to Firebase (app-to-app chat)
    final conversationId = _getConversationId(cleanedNumber);
    final hasInternet = await _checkInternet();

    if (hasInternet) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .add({
        'sender': 'me',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // fallback to SMS
      await telephony.sendSms(to: cleanedNumber, message: text, isMultipart: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No internet — sent via SMS")),
      );
    }

    _controller.clear();
    setState(() {});
  }

  String _getConversationId(String number) {
    // simple sorted ID to make it unique between two users
    final ids = ['me', number]..sort();
    return ids.join('-');
  }

  Future<bool> _checkInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.mobile || connectivity == ConnectivityResult.wifi;
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messageBox.values
        .where((msg) => msg['phone'] == widget.phoneNumber)
        .toList();

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

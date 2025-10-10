// lib/message.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  final String companionId; // ID of the companion

  const MessageScreen({super.key, required this.companionId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late DatabaseReference _chatRef;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPhone = prefs.getString('phone') ?? "";

    _userId = storedPhone.isNotEmpty ? storedPhone : "unknown_user";

    // Sort IDs for unique chat path
    final sortedIds = [_userId, widget.companionId]..sort();
    final chatId = "${sortedIds[0]}_${sortedIds[1]}";

    _chatRef = FirebaseDatabase.instance.ref().child('chats/$chatId/messages');

    // Listen for database changes
    _chatRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) {
        setState(() => messages = []);
        return;
      }

      final temp = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        temp.add({
          'id': key,
          'senderId': value['senderId'] ?? '',
          'text': value['text'] ?? '',
          'timestamp': value['timestamp'] ?? '',
        });
      });

      // Sort by timestamp
      temp.sort((a, b) {
        try {
          return DateTime.parse(a['timestamp'])
              .compareTo(DateTime.parse(b['timestamp']));
        } catch (_) {
          return 0;
        }
      });

      setState(() => messages = temp);
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    _chatRef.push().set({
      'senderId': _userId,
      'text': _controller.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['senderId'] == _userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.pinkAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
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
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.pinkAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

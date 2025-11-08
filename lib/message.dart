// lib/message.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageScreen extends StatefulWidget {
  final String companionId; // e.g., "companion_33333"
  const MessageScreen({super.key, required this.companionId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _msgController = TextEditingController();
  late DatabaseReference _chatRef;
  String _userId = "";
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initializes the chat by loading user ID and connecting to Firebase
  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? "";

    // 🧠 Debug prints for diagnostics
    print("DEBUG (user chat) → loaded userId: $_userId");
    print("DEBUG (user chat) → companionId: ${widget.companionId}");

    if (_userId.isEmpty || widget.companionId.isEmpty) {
      print("ERROR → Missing IDs, cannot initialize chat.");
      return;
    }

    // Create unified chat path (sorted IDs)
    final sortedIds = [_userId, widget.companionId]..sort();
    final chatId = "${sortedIds[0]}_${sortedIds[1]}";
    _chatRef = FirebaseDatabase.instance.ref("chats/$chatId/messages");

    print("DEBUG (user chat) → chat path: chats/$chatId/messages");

    _listenForMessages();
  }

  /// Realtime listener for message updates
  void _listenForMessages() {
    _chatRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final temp = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value);
        return val;
      }).toList();

      temp.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      setState(() => _messages = temp);

      print("DEBUG (user chat) → ${_messages.length} messages loaded");
    });
  }

  /// Sends message to Firebase
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    print("DEBUG (user chat) → sending message from: $_userId");
    print("DEBUG (user chat) → chat path: ${_chatRef.path}");
    print("DEBUG (user chat) → text: $text");

    final msgData = {
      "sender": _userId,
      "text": text,
      "timestamp": ServerValue.timestamp,
    };

    try {
      await _chatRef.push().set(msgData);
      print("DEBUG (user chat) → message pushed successfully ✅");
    } catch (e) {
      print("ERROR (user chat) → $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["sender"] == _userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.pinkAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
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

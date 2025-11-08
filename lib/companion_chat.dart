// lib/companion_chat.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanionChatScreen extends StatefulWidget {
  final String mainUserId; // e.g., "user_11111"
  final String companionId; // e.g., "companion_33333"

  const CompanionChatScreen({
    super.key,
    required this.mainUserId,
    required this.companionId,
  });

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  late DatabaseReference _chatRef;
  String _userId = "";
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initialize chat by loading companion ID and setting up Firebase path
  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? "";

    // 🧠 debug output for diagnostics
    print("DEBUG (companion chat) → loaded userId: $_userId");
    print("DEBUG (companion chat) → mainUserId: ${widget.mainUserId}");
    print("DEBUG (companion chat) → companionId: ${widget.companionId}");

    if (_userId.isEmpty || widget.mainUserId.isEmpty) {
      print("ERROR → Missing IDs, cannot initialize chat.");
      return;
    }

    // build a consistent chat path
    final sortedIds = [widget.mainUserId, widget.companionId]..sort();
    final chatId = "${sortedIds[0]}_${sortedIds[1]}";
    _chatRef = FirebaseDatabase.instance.ref("chats/$chatId/messages");

    print("DEBUG (companion chat) → chat path: chats/$chatId/messages");

    _listenForMessages();
  }

  /// listen for messages in realtime
  void _listenForMessages() {
    _chatRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final temp = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value);
        return val;
      }).toList();

      temp.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      setState(() => _messages = temp);

      print("DEBUG (companion chat) → ${_messages.length} messages loaded");
    });
  }

  /// send a new message
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    print("DEBUG (companion chat) → sending from: $_userId");
    print("DEBUG (companion chat) → path: ${_chatRef.path}");
    print("DEBUG (companion chat) → text: $text");

    final msgData = {
      "sender": _userId,
      "text": text,
      "timestamp": ServerValue.timestamp,
    };

    try {
      await _chatRef.push().set(msgData);
      print("DEBUG (companion chat) → message pushed successfully ✅");
    } catch (e) {
      print("ERROR (companion chat) → $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with User")),
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[700] : Colors.grey[300],
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
                  icon: const Icon(Icons.send, color: Colors.blue),
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

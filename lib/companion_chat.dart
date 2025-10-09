// lib/companion_chat.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanionChatScreen extends StatefulWidget {
  final String companionId;
  final String mainUserId;

  const CompanionChatScreen({
    super.key,
    required this.companionId,
    required this.mainUserId,
  });

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final TextEditingController _controller = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _chatRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.mainUserId)
          .collection('chats')
          .doc(widget.companionId)
          .collection('messages');

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();
    _controller.clear();

    await _chatRef.add({
      'senderId': widget.companionId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatRef.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[docs.length - index - 1].data();
                    final isMe = data['senderId'] == widget.companionId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(data['message']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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

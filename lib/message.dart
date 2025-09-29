import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber; // For WhatsApp forwarding

  const MessageScreen({
    super.key,
    required this.contactName,
    required this.phoneNumber,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('messages'); // Make sure Hive.initFlutter() and openBox is called in main()
  }

  /// Save to local DB + send to WhatsApp
  void _sendMessage(String text) async {
    final msg = {
      "contact": widget.contactName,
      "text": text,
      "fromMe": true,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _box.add(msg);

    final url =
        "https://wa.me/${widget.phoneNumber}?text=${Uri.encodeComponent(text)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp not available")),
      );
    }
  }

  /// Call this when reading WhatsApp notifications (later)
  void _receiveMessage(String text) {
    final msg = {
      "contact": widget.contactName,
      "text": text,
      "fromMe": false,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    _box.add(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contactName)),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box box, _) {
                final msgs = box.values
                    .where((m) => m["contact"] == widget.contactName)
                    .toList();
                msgs.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final isMe = m["fromMe"] == true;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m["text"],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late Box _chatMemory;

  Map<String, String> _compressedModel = {}; // small token-response map

  final Map<String, String> taskLinks = {
    'consumer complaint': 'https://consumerhelpline.gov.in/',
    'cyber crime': 'https://cybercrime.gov.in/Webform/Accept.aspx',
    'police complaint': 'https://www.edaakhil.nic.in/',
    'public grievance': 'https://pgportal.gov.in/',
    'human rights': 'https://www.hrcnet.nic.in/HRCNet/public/webcomplaint.aspx',
    'lokpal': 'https://lokpalonline.gov.in/',
    'postal grievance': 'https://www.indiapost.gov.in/grievance-redressal/file-a-complaint',
  };

  @override
  void initState() {
    super.initState();
    _initMemory();
    _loadCompressedModel();
  }

  Future<void> _initMemory() async {
    _chatMemory = await Hive.openBox('chat_memory');
    final storedChats = _chatMemory.get('chats', defaultValue: []);
    setState(() {
      _messages.addAll(List<Map<String, String>>.from(storedChats));
    });
  }

  Future<void> _saveChats() async {
    await _chatMemory.put('chats', _messages);
  }

  /// Load a small compressed model from JSON file in assets/documents
  Future<void> _loadCompressedModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/compressed_model.json');

    if (!await modelFile.exists()) {
      print("Compressed model file missing at ${modelFile.path}");
      return;
    }

    try {
      final content = await modelFile.readAsString();
      _compressedModel = Map<String, String>.from(jsonDecode(content));
      print("Compressed model loaded successfully!");
    } catch (e) {
      print("Error loading compressed model: $e");
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() => _messages.add({'sender': 'user', 'text': text}));
    _controller.clear();
    _generateBotReply(text);
  }

  Future<void> _generateBotReply(String userText) async {
    userText = userText.trim().toLowerCase();
    String reply = "";

    // Check for task links first
    String? foundLink;
    taskLinks.forEach((keyword, url) {
      if (userText.contains(keyword)) foundLink = url;
    });

    if (foundLink != null) {
      reply = "I found a link that can help you: $foundLink\nTap to open it.";
    } else if (_compressedModel.isNotEmpty) {
      // Basic token matching
      reply = _compressedModel.entries
          .firstWhere(
            (entry) => userText.contains(entry.key),
            orElse: () => const MapEntry("fallback", ""),
          )
          .value;

      if (reply.isEmpty) {
        // fallback responses
        List<String> fallbackReplies = [
          "That's interesting! Can you tell me more?",
          "Hmm, I see. What else?",
          "Oh! Go on…",
          "Got it! Anything else you'd like to share?",
          "I understand. Can you explain a bit more?"
        ];
        reply = (fallbackReplies..shuffle()).first;
      }
    } else {
      // fallback if model not loaded
      List<String> fallbackReplies = [
        "That's interesting! Can you tell me more?",
        "Hmm, I see. What else?",
        "Oh! Go on…",
        "Got it! Anything else you'd like to share?",
        "I understand. Can you explain a bit more?"
      ];
      reply = (fallbackReplies..shuffle()).first;
    }

    setState(() => _messages.add({'sender': 'bot', 'text': reply}));
    _saveChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Assistant 🤖"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.pink[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Linkify(
                      text: msg['text']!,
                      onOpen: (link) async {
                        final url = Uri.parse(link.url);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.black87,
                        fontSize: 16,
                      ),
                      linkStyle: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Ask me anything...",
                border: InputBorder.none,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.pink),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}

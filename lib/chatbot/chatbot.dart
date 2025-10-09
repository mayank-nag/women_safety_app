import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'local_brain.dart'; // optional fallback logic

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late Box _chatMemory;
  late GenerativeModel _model;
  late ChatSession _chat;

  final LocalBotBrain _fallbackBot = LocalBotBrain();

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
    _initGemini();
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

  Future<void> _initGemini() async {
    const apiKey = "YOUR_GEMINI_API_KEY_HERE"; // 🔑 Replace with your Gemini API key
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    _chat = _model.startChat();
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

    // 1️⃣ Check for government task links first
    String? foundLink;
    taskLinks.forEach((keyword, url) {
      if (userText.contains(keyword)) foundLink = url;
    });

    if (foundLink != null) {
      reply = "I found a link that can help you: $foundLink\nTap to open it.";
    } else {
      try {
        // 2️⃣ Use Gemini API for intelligent replies
        final response = await _chat.sendMessage(Content.text(userText));
        reply = response.text ?? "";

        // 3️⃣ If Gemini doesn’t respond, use local fallback
        if (reply.isEmpty) {
          reply = _fallbackBot.getReply(userText);
        }
      } catch (e) {
        reply = "⚠️ Sorry, I'm having trouble connecting right now.\n${_fallbackBot.getReply(userText)}";
      }
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
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
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

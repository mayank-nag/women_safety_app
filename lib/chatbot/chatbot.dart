// lib/chatbot.dart
import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  // Extended hardcoded info for categories and chatbot responses
  final Map<String, String> _info = {
    "IPC": """
⚖ IPC Sections Protecting Women
- Section 354 – Outraging a woman’s modesty.
- Section 354A – Sexual harassment.
- Section 354B – Assault with intent to disrobe.
- Section 354C – Voyeurism.
- Section 354D – Stalking.
- Section 376 – Rape.
- Section 376A–376E – Aggravated rape.
- Section 498A – Cruelty by husband/relatives.
- Section 509 – Insulting a woman’s modesty.
""",
    "Special Acts": """
🛡 Special Acts for Women
- Dowry Prohibition Act, 1961.
- Protection from Domestic Violence Act, 2005.
- Sexual Harassment at Workplace Act, 2013.
- Indecent Representation of Women (Prohibition) Act, 1986.
- Immoral Traffic (Prevention) Act, 1956.
- Maternity Benefit Act, 1961.
- Prohibition of Child Marriage Act, 2006.
""",
    "Cyber Safety": """
💻 Cyber Safety Laws (IT Act, 2000)
- Section 66E – Capturing/sharing private images without consent.
- Section 67 – Publishing/transmitting obscene material online.
- Section 72 – Breach of confidentiality or privacy.
""",
    "Helpline": """
📞 Important Helpline Numbers
- Women Helpline: 1091
- Domestic Violence Helpline: 181
- National Commission for Women: 011-26942369 / 26944754
- Police Emergency: 112
""",
    "new button" : """
working """,
  };

  // Additional static response dataset
  final Map<String, List<String>> _staticResponses = {
    "greetings": [
      "Hello! I hope you're safe today. 💖",
      "Hi there! How can I assist you? 😊",
      "Hey! I'm here to help you stay safe. 🌸",
      "Hello! Remember, you're not alone. 💕"
    ],
    "farewell": [
      "Take care and stay safe! 🌷",
      "Goodbye! Reach out anytime. 💌",
      "Stay alert and safe! 🚶‍♀️"
    ],
    "thanks": [
      "You're welcome! Always here for support. 🌸",
      "No problem! Glad I could help. 😊",
      "Happy to assist! 💖"
    ],
    "emotionalSupport": [
      "I'm here to listen. Remember, talking to someone you trust can help. ❤️",
      "It's okay to feel this way. You are strong and not alone. 💕",
      "Take deep breaths. You are safe and cared for. 🌸"
    ],
    "safetyTips": [
      """
Here are some important personal safety tips:
- Always be aware of your surroundings. 👀
- Share your location with a trusted friend when going out alone. 📍
- Trust your instincts; if something feels wrong, leave immediately. 🚶‍♀️
- Keep emergency numbers saved on your phone. 📞
- Avoid sharing private info or photos online. 💻
""",
      """
Traveling alone? Stay safe with these tips:
- Stick to well-lit, populated areas. 🌟
- Use trusted transportation apps or official taxis. 🚖
- Keep your phone charged and accessible. 🔋
- Inform someone about your route and expected arrival time. 🕒
"""
    ],
    "general": [
      "I can provide safety tips, helpline numbers, cyber safety info, and legal info for women. 😊",
      "Feel free to ask me about personal safety, cyber laws, or helplines. 💌",
      "Remember, staying informed keeps you safer. 💖"
    ],
    "confused": [
      "I’m here to help! Could you please clarify your question? 🤔",
      "Sorry, I didn't understand that. Can you rephrase? 🌸"
    ]
  };

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({"text": text, "isUser": false});
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleCategory(String category) {
    _addBotMessage(_info[category]!);
  }

  // Extended chatbot response logic
  void _handleUserMessage(String message) {
    _messages.add({"text": message, "isUser": true});
    _textController.clear();

    String reply = _staticResponses["confused"]!.first;

    String msgLower = message.toLowerCase();

    // Greeting
    if (msgLower.contains("hi") || msgLower.contains("hello") || msgLower.contains("hey")) {
      reply = (_staticResponses["greetings"]!..shuffle()).first;
    } 
    // Asking for help or advice
    else if (msgLower.contains("help") || msgLower.contains("advice")) {
      reply =
          "Sure! I can provide info on legal rights, cyber safety, personal safety tips, or helpline numbers. 📞";
    } 
    // Emotional support
    else if (msgLower.contains("sad") ||
        msgLower.contains("depressed") ||
        msgLower.contains("stress") ||
        msgLower.contains("anxious") ||
        msgLower.contains("worried")) {
      reply = (_staticResponses["emotionalSupport"]!..shuffle()).first;
    } 
    // Thanks
    else if (msgLower.contains("thank")) {
      reply = (_staticResponses["thanks"]!..shuffle()).first;
    } 
    // Cyber safety
    else if (msgLower.contains("cyber") || msgLower.contains("online") || msgLower.contains("internet")) {
      reply = _info["Cyber Safety"]!;
    } 
    // Legal queries
    else if (msgLower.contains("law") || msgLower.contains("ipc") || msgLower.contains("legal")) {
      reply = _info["IPC"]!;
    } 
    // Safety tips
    else if (msgLower.contains("tips") || msgLower.contains("safe") || msgLower.contains("safety")) {
      reply = (_staticResponses["safetyTips"]!..shuffle()).first;
    } 
    // Night or travel safety
    else if (msgLower.contains("night") || msgLower.contains("alone") || msgLower.contains("travel")) {
      reply = (_staticResponses["safetyTips"]!..shuffle()).last;
    } 
    // Asking who bot is
    else if (msgLower.contains("who are you") || msgLower.contains("your name")) {
      reply = "I'm your Women Safety Assistant Bot. Here to provide info, support, and tips. 💕";
    } 
    // Generic questions
    else if (msgLower.contains("can you") || msgLower.contains("do you")) {
      reply = (_staticResponses["general"]!..shuffle()).first;
    }

    _addBotMessage(reply);
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: SelectableText(
          message['text'],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _info.keys.map((category) {
        return ElevatedButton(
          onPressed: () => _handleCategory(category),
          child: Text(category),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Women Safety Chatbot"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  "Select a topic to learn:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildCategoryButtons(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          _handleUserMessage(_textController.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

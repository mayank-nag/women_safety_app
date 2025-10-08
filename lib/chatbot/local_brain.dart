import 'dart:math';

class LocalBotBrain {
  final Map<String, List<String>> responses = {
    "greeting": [
      "Hey there! How can I help you today?",
      "Hi! I’m your safety assistant. Need any help?",
      "Hello! You can ask me about safety tips or emergency support."
    ],
    "help": [
      "If you’re in danger, press the SOS button or share your location.",
      "You can use the SOS feature to alert your contacts immediately.",
      "Stay calm. I can guide you to safety. Try saying 'emergency contacts'."
    ],
    "safe_tips": [
      "Always share your location with a trusted contact when travelling alone.",
      "Avoid isolated areas at night and keep emergency numbers saved.",
      "Trust your instincts — if something feels off, it probably is."
    ],
    "emergency_contacts": [
      "Open your emergency tab to send alerts instantly.",
      "Tap on the 'Emergency' section to contact nearby help.",
      "I can show you how to share your live location with emergency contacts."
    ],
    "default": [
      "I’m not sure about that, but I can help with safety tips, emergencies, or contacts.",
      "Can you rephrase that? I’m here to guide you about safety and emergencies."
    ]
  };

  final Map<String, List<String>> intentKeywords = {
    "greeting": ["hi", "hello", "hey"],
    "help": ["help", "assist", "support"],
    "safe_tips": ["tip", "advice", "safety", "safe"],
    "emergency_contacts": ["contact", "call", "emergency", "number"],
  };

  String getReply(String userInput) {
    final input = userInput.toLowerCase();
    String matchedIntent = "default";
    int bestScore = 0;

    for (final entry in intentKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (input.contains(keyword)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        matchedIntent = entry.key;
      }
    }

    final possibleReplies = responses[matchedIntent] ?? responses["default"]!;
    return possibleReplies[Random().nextInt(possibleReplies.length)];
  }
}

// companion.dart
import 'package:flutter/material.dart';

class CompanionScreen extends StatelessWidget {
  const CompanionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: const Text('Companion'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // TODO: QR generator logic
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                // TODO: open profile
              },
              child: const CircleAvatar(
                backgroundColor: Colors.yellow,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.brown[400],
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Main User Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location / Map section (40-50% of screen)
            Container(
              height: screenHeight * 0.45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Main User Location / Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chat section (remaining space)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          chatBubble('Hello! How are you?', false),
                          chatBubble('I am fine, thank you!', true),
                          chatBubble('Ready for our trip?', false),
                        ],
                      ),
                    ),
                    // Message input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue[700],
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatBubble(String message, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSentByUser ? Colors.white : Colors.blue[900],
          ),
        ),
      ),
    );
  }
}

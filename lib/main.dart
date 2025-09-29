import 'package:flutter/material.dart';
import 'location.dart';
import 'message.dart';
import 'emergency.dart';
import 'sos.dart';
import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Women's Safety App",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Women's Safety App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // navigate to settings screen if you add one
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // SOS Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(60),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SosScreen()),
                  );
                },
                child: const Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Quick Access Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickButton(
                    context,
                    Icons.phone,
                    "Call 112",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                      );
                    },
                  ),
                  _buildQuickButton(
                    context,
                    Icons.location_on,
                    "Share Location",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationScreen()),
                      );
                    },
                  ),
                  _buildQuickButton(
                    context,
                    Icons.message,
                    "Message",
                    () {
                      // ✅ Fixed: Using placeholder contact
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MessageScreen(
                            contactName: "Alice",
                            phoneNumber: "+911234567890",
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickButton(
                    context,
                    Icons.contacts,
                    "Emergency Contacts",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pink, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.pink),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

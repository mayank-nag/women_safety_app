import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Update location (overwrite)
  Future<void> updateLocation(String userId, double lat, double lng) async {
    await _db.child('users/$userId/location').set({
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send chat message (append)
  Future<void> sendMessage(
      {required String userId,
      required String companionId,
      required String text}) async {
    final ref = _db.child('users/$userId/chats/$companionId/messages');
    final key = ref.push().key!;
    await ref.child(key).set({
      'from': userId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Fetch user location
  DatabaseReference locationRef(String userId) {
    return _db.child('users/$userId/location');
  }

  // Fetch chat messages
  DatabaseReference chatRef(String userId, String companionId) {
    return _db.child('users/$userId/chats/$companionId/messages');
  }
}

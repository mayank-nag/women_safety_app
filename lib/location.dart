import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// 🔑 Replace with your Google Places API key
const String GOOGLE_PLACES_API_KEY = 'AIzaSyBUH4K0VKMcKfiW1csqBYWpBSk2vG7TNos';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  Circle? _radiusCircle;

  static const double radiusMeters = 100.0;

  // Nearby device counts
  int totalDevices = 0;
  int unknownDevices = 0;
  int contactDevices = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnack("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition();
    _updateUserPosition(pos);
  }

  void _updateUserPosition(Position pos) {
    _currentPosition = LatLng(pos.latitude, pos.longitude);

    _addUserMarker();
    _drawRadiusCircle();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 16),
    );

    _fetchNearbyPlaces('hospital');
    _fetchNearbyPlaces('police');

    _simulateNearbyPeople();
  }

  void _addUserMarker() {
    _markers.removeWhere((m) => m.markerId.value == 'me');
    _markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: "You are here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    setState(() {});
  }

  void _drawRadiusCircle() {
    _radiusCircle = Circle(
      circleId: const CircleId('radius'),
      center: _currentPosition!,
      radius: radiusMeters,
      strokeColor: Colors.blue.withOpacity(0.5),
      fillColor: Colors.blue.withOpacity(0.1),
      strokeWidth: 2,
    );
    setState(() {});
  }

  void _simulateNearbyPeople() {
    if (_currentPosition == null) return;

    _markers.removeWhere((m) => m.markerId.value.startsWith('user_'));

    final fakeUsers = [
      LatLng(_currentPosition!.latitude + 0.0005, _currentPosition!.longitude + 0.0005),
      LatLng(_currentPosition!.latitude - 0.0004, _currentPosition!.longitude + 0.0003),
      LatLng(_currentPosition!.latitude + 0.0002, _currentPosition!.longitude - 0.0006),
    ];

    for (int i = 0; i < fakeUsers.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('user_$i'),
          position: fakeUsers[i],
          infoWindow: InfoWindow(title: 'User ${i + 1}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    // Update counts
    totalDevices = fakeUsers.length;
    contactDevices = 1; // Example: one contact nearby
    unknownDevices = totalDevices - contactDevices;

    setState(() {});
  }

  Future<void> _fetchNearbyPlaces(String type) async {
    if (_currentPosition == null) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=1000&type=$type&key=$GOOGLE_PLACES_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));
      print("Places API response: ${response.body}");

      if (response.statusCode != 200) {
        _showSnack("Places API error: ${response.statusCode}");
        return;
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        _showSnack("Places API status: ${data['status']}");
        return;
      }

      final results = data['results'] as List<dynamic>;
      for (var place in results.take(8)) {
        final loc = place['geometry']['location'];
        final LatLng pos = LatLng(loc['lat'], loc['lng']);
        final String placeId = place['place_id'];

        _markers.add(
          Marker(
            markerId: MarkerId('place_$placeId'),
            position: pos,
            infoWindow: InfoWindow(title: place['name'], snippet: place['vicinity']),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              type == 'hospital' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
      setState(() {});
    } catch (e) {
      _showSnack("Error fetching $type: $e");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 16),
                  markers: _markers,
                  circles: _radiusCircle != null ? {_radiusCircle!} : {},
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                _buildBottomPanel(),
              ],
            ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total devices nearby: $totalDevices", style: const TextStyle(fontSize: 16)),
            Text("Unknown: $unknownDevices", style: const TextStyle(fontSize: 16, color: Colors.red)),
            Text("Contacts: $contactDevices", style: const TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

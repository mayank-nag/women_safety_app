import 'dart:async';
//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:shared_preferences/shared_preferences.dart';

// Hardcoded Police Stations (Red)
final List<Map<String, dynamic>> policeStations = [
  {
    'name': 'Police Station Mahatma Gandhi Nagar',
    'lat': 26.8903,
    'lng': 75.8107,
    'address': 'Mahatma Gandhi Nagar, Sitapura, Jaipur'
  },
  {
    'name': 'Pratap Nagar Police Station',
    'lat': 26.8025,
    'lng': 75.8440,
    'address': 'Sector 11, Pratap Nagar, Jaipur'
  },
  {
    'name': 'Sanganer Police Station',
    'lat': 26.8195,
    'lng': 75.7970,
    'address': 'Dada Gurudev Nagar, Sanganer, Jaipur'
  },
];

// Hardcoded Hospitals (Blue)
final List<Map<String, dynamic>> hospitals = [
  {
    'name': 'Sanganer Sadar Hospital',
    'lat': 26.8578,
    'lng': 75.7985,
    'address': 'Sanganer, Jaipur'
  },
  {
    'name': 'CS Hospital',
    'lat': 26.8904,
    'lng': 75.7287,
    'address': 'Heerapura, Jaipur'
  },
  {
    'name': 'Narayana Hospital',
    'lat': 26.7949,
    'lng': 75.8254,
    'address': 'Sector 28, Pratap Nagar, Jaipur'
  },
];

// Hardcoded companion location
final LatLng hardcodedCompanionLocation = LatLng(27.7885479, 75.8343913);

class LocationScreen extends StatefulWidget {
  final String userId; // Main user ID
  const LocationScreen({super.key, required this.userId});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng? currentUserLocation;

  late DatabaseReference _userRef;
  final Set<Marker> _markers = {};
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initReferences();
  }

  Future<void> _initReferences() async {
    _userRef = FirebaseDatabase.instance.ref('users/${widget.userId}/location');
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnack("Enable location services.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _updateUserLocation(pos);

    _locationTimer?.cancel();
    _locationTimer =
        Timer.periodic(const Duration(minutes: 2), (_) async {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateUserLocation(pos);
    });
  }

  void _updateUserLocation(Position pos) {
    currentUserLocation = LatLng(pos.latitude, pos.longitude);

    // Update Firebase
    _userRef.set({
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _updateMarkers();
    _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentUserLocation!, 16));
  }

  void _updateMarkers() {
    final Set<Marker> markers = {};

    // User (pink)
    if (currentUserLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: currentUserLocation!,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
    }

    // Companion (green) - hardcoded
    markers.add(Marker(
      markerId: const MarkerId('companion'),
      position: hardcodedCompanionLocation,
      infoWindow: const InfoWindow(title: 'Companion'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // Police (red)
    for (var ps in policeStations) {
      markers.add(Marker(
        markerId: MarkerId(ps['name']),
        position: LatLng(ps['lat'], ps['lng']),
        infoWindow: InfoWindow(title: ps['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Hospitals (blue)
    for (var h in hospitals) {
      markers.add(Marker(
        markerId: MarkerId(h['name']),
        position: LatLng(h['lat'], h['lng']),
        infoWindow: InfoWindow(title: h['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location")),
      body: currentUserLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: currentUserLocation!, zoom: 16),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}

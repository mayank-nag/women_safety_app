// lib/companion_location.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanionLocationScreen extends StatefulWidget {
  final String companionId;
  final String userId; // main user ID

  const CompanionLocationScreen({
    super.key,
    required this.companionId,
    required this.userId,
  });

  @override
  State<CompanionLocationScreen> createState() => _CompanionLocationScreenState();
}

class _CompanionLocationScreenState extends State<CompanionLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _mainUserLocation;
  LatLng? _companionLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _checkPermissions();
    await _fetchCompanionLocation();
    await _fetchMainUserLocation();
    _updateMarkers();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _fetchCompanionLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _companionLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error fetching companion location: $e');
    }
  }

  Future<void> _fetchMainUserLocation() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['location'] != null) {
          setState(() {
            _mainUserLocation = LatLng(
              data['location']['latitude'],
              data['location']['longitude'],
            );
          });
        }
      }
    } catch (e) {
      print('Error fetching main user location: $e');
    }
  }

  void _updateMarkers() {
    Set<Marker> newMarkers = {};
    if (_mainUserLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('mainUser'),
          position: _mainUserLocation!,
          infoWindow: const InfoWindow(title: "Main User"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    if (_companionLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('companion'),
          position: _companionLocation!,
          infoWindow: const InfoWindow(title: "You"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    setState(() => _markers = newMarkers);
  }

  Future<void> _refreshLocations() async {
    await _fetchCompanionLocation();
    await _fetchMainUserLocation();
    _updateMarkers();

    if (_mainUserLocation != null) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(_mainUserLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mainUserLocation == null && _companionLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Companion Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocations,
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _mainUserLocation ?? _companionLocation ?? const LatLng(26.9124, 75.7873),
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}

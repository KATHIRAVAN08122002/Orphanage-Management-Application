import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // ✅ Step 1: Check and Request Permissions
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If denied again, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required to use this feature.")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, open app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location permissions from settings.")),
      );
      return;
    }

    // ✅ Step 2: Get Current Location
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });

      // Move Camera to Current Location
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng!),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Orphanages")),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng!,
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        myLocationEnabled: true, // ✅ Show user location
      ),
    );
  }
}

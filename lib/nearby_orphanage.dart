import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NearbyOrphanagesPage extends StatefulWidget {
  @override
  _NearbyOrphanagesPageState createState() => _NearbyOrphanagesPageState();
}

class _NearbyOrphanagesPageState extends State<NearbyOrphanagesPage> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  List<Marker> orphanageMarkers = [];
  bool _mapRendered = false; // Track if map is rendered

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      print("✅ Current Location: $_currentLocation");

      // Wait for the map to be ready before moving the camera
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(_currentLocation!, 15.0);
        } else {
          print("⚠️ Widget is not mounted, skipping map movement");
        }
      });


    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }

  Future<void> _fetchNearbyOrphanages() async {
    if (_currentLocation == null) return;

    QuerySnapshot orphanagesSnapshot =
    await FirebaseFirestore.instance.collection('orphanages').get();

    List<Marker> markers = [];

    for (var doc in orphanagesSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?; // Safe casting

      if (data == null || !data.containsKey('loc')) {
        print("⚠️ Skipping orphanage ${doc.id} - 'loc' field is missing");
        continue; // Skip invalid documents
      }

      var locationData = data['loc'];
      if (locationData is List && locationData.length == 2) {
        double orphanageLat = locationData[0];
        double orphanageLng = locationData[1];
        String title = data['title'] ?? 'Unknown Orphanage';

        double distance = Geolocator.distanceBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          orphanageLat,
          orphanageLng,
        );

        if (distance <= 5000) {
          markers.add(
            Marker(
              point: LatLng(orphanageLat, orphanageLng),
              width: 120, // Increased width for better spacing
              height: 60, // Increased height to prevent overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 40), // Blue location icon
                  SizedBox(height: 2), // Small space between icon and text
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Slight transparency for better readability
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                    ),
                    child: Text(
                      doc['title'], // Display orphanage title
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Prevents overflow issue
                    ),
                  ),
                ],
              ),
            ),



          );
        }
      } else {
        print("⚠️ Orphanage ${doc.id} has an invalid 'loc' format");
      }
    }

    setState(() {
      orphanageMarkers = markers;
    });

    print("✅ Total orphanages found within 5km: ${orphanageMarkers.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Orphanages")),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation!,
          initialZoom: 15.0,
          onMapReady: () {
            if (!_mapRendered) {
              setState(() {
                _mapRendered = true;
              });
              print("✅ Map is now rendered. Fetching orphanages...");
              _fetchNearbyOrphanages(); // Fetch orphanages when map is ready
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: Icon(Icons.location_pin, color: Colors.red, size: 40), // User location
              ),
              ...orphanageMarkers, // Orphanage markers
            ],
          ),
        ],
      ),
    );
  }
}

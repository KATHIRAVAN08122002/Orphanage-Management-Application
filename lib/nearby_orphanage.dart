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
  bool _mapRendered = false;

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

      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _mapController.move(_currentLocation!, 15.0);
        }
      });

      _fetchNearbyOrphanages(); // Fetch orphanages after location
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
      var data = doc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('loc')) continue;

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

        if (distance <= 100000) {
          markers.add(
            Marker(
              point: LatLng(orphanageLat, orphanageLng),
              width: 140,
              height: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 40),
                  SizedBox(height: 4),
                  Container(
                    width: 120,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 3)
                      ],
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    setState(() {
      orphanageMarkers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Orphanages", style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),
      body: Stack(
        children: [
          _currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 15.0,
              onMapReady: () {
                if (!_mapRendered) {
                  setState(() => _mapRendered = true);
                  _fetchNearbyOrphanages();
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
                    child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                  ...orphanageMarkers,
                ],
              ),
            ],
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, 15.0);
                }
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

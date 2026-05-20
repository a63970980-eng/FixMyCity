import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Functions/bottomnav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? currentPosition;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() => currentPosition = position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(selectedIndex: 1),

      appBar: AppBar(
        title: const Text('خريطة البلاغات'),
        centerTitle: true,
        elevation: 2,
      ),

      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('complaints').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('حدث خطأ في تحميل البيانات'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final List<Marker> markers = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final lat = data['latitude'];
                  final lng = data['longitude'];

                  if (lat == null || lng == null) {
                    return null;
                  }

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 35,
                    ),
                  );
                }).whereType<Marker>().toList();

                return FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                    ),
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),

                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
    );
  }
}
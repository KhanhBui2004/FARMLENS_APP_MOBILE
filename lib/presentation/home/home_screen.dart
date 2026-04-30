import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _timeValue = 0.62;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Đợi frame đầu tiên render xong rồi mới show map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _mapReady = true);
      }
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(16.0544, 108.2022),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width > 900 ? 760.0 : double.infinity;

    return Scaffold(
      body: GoogleMap(
        // mapType: MapType.satellite,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
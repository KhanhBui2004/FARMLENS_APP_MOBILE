import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFullscreenSelector extends StatefulWidget {
  final CameraPosition initialCamera;
  final LatLng? initialSelected;

  const MapFullscreenSelector({
    super.key,
    required this.initialCamera,
    this.initialSelected,
  });

  @override
  State<MapFullscreenSelector> createState() => _MapFullscreenSelectorState();
}

class _MapFullscreenSelectorState extends State<MapFullscreenSelector> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTap(LatLng position) {
    setState(() => _selected = position);
  }

  @override
  Widget build(BuildContext context) {
    final marker = _selected == null
        ? <Marker>{}
        : {
            Marker(
              markerId: const MarkerId('selected_region'),
              position: _selected!,
            ),
          };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí'),
        actions: [
          TextButton(
            onPressed: _selected == null
                ? null
                : () => Navigator.pop(context, _selected),
            child: const Text('Sử dụng vị trí'),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: widget.initialCamera,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        liteModeEnabled: true,
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        markers: marker,
      ),
      floatingActionButton: _selected == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context, _selected),
              icon: const Icon(Icons.check),
              label: const Text('Xác nhận vị trí'),
            ),
    );
  }
}

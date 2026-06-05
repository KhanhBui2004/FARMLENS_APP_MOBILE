import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPanel extends StatelessWidget {
  final CameraPosition initialCamera;
  final MapType mapType;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onSelectRegion;
  final VoidCallback onToggleMapType;
  final String selectedRegionLabel;
  final Set<Marker> selectionMarkers;

  const MapPanel({
    super.key,
    required this.initialCamera,
    required this.mapType,
    required this.onMapCreated,
    required this.onSelectRegion,
    required this.onToggleMapType,
    required this.selectedRegionLabel,
    required this.selectionMarkers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            GoogleMap(
              mapType: mapType,
              initialCameraPosition: initialCamera,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: true,
              onMapCreated: onMapCreated,
              markers: selectionMarkers,
            ),
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        selectedRegionLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onToggleMapType,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.layers, color: Colors.green[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              width: 50,
              height: 50,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 27, 94, 32).withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: onSelectRegion,
                  icon: const Icon(Icons.crop_free),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

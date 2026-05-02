import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/header.dart';
import 'widgets/map_panel.dart';
import 'widgets/stats_actions.dart';
import 'widgets/export_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  MapType _currentMapType = MapType.normal;
  DateTime _selectedDate = DateTime.now();
  String _selectedRegion = 'Selected area: Central farm block';
  double _calculatedArea = 125.5;
  double _changePercent = 12.4;
  double _modelConfidence = 91.0;
  double _cloudCoverage = 18.0;
  Set<Polygon> _cropMasks = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  void _handleMenuAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected $action')));
  }

  void _selectRegion() {
    // keep simple: call map panel's selection UI
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose analysis area',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.edit_location_alt,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Draw on map'),
                  subtitle: const Text('Trace a polygon for the target field'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(
                      () => _selectedRegion =
                          'Selected area: Polygon drawn on map',
                    );
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Polygon drawing mode opened'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.map_outlined, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text('Pick from map'),
                  subtitle: const Text('Tap a predefined region on the map'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(
                      () => _selectedRegion = 'Selected area: Region from map',
                    );
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Map region picker opened')),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.bookmark_outline,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Saved regions'),
                  subtitle: const Text('Reuse a previously analyzed area'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(
                      () => _selectedRegion = 'Selected area: Saved region',
                    );
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Saved regions opened')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _runAnalysis() {
    // Generate simulated crop mask polygons
    final List<LatLng> cropBoundary = [
      const LatLng(16.050, 108.198),
      const LatLng(16.055, 108.198),
      const LatLng(16.058, 108.206),
      const LatLng(16.052, 108.208),
      const LatLng(16.048, 108.203),
    ];

    setState(() {
      _cropMasks = {
        Polygon(
          polygonId: const PolygonId('crop_mask_main'),
          points: cropBoundary,
          fillColor: const Color(0xFF4CAF50).withValues(alpha: 0.35),
          strokeColor: const Color(0xFF2E7D32),
          strokeWidth: 3,
        ),
      };
      _calculatedArea = 132.8;
      _changePercent = 8.9;
      _modelConfidence = 93.6;
      _cloudCoverage = 14.2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running satellite segmentation pipeline...'),
      ),
    );
  }

  void _exportReport(String format) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Exporting report as $format')));

  void _onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6FBF5),
                  Color(0xFFEAF4EA),
                  Color(0xFFFDFEFE),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF3F8E5A).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: HomeHeader(
                      onMenuSelected: _handleMenuAction,
                      title: 'FarmLens Dashboard',
                      subtitle:
                          'Satellite monitoring, U-Net segmentation and crop analytics',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Overview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Operational overview',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Choose an area, run analysis, visualize results, and export reports in one flow.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.satellite_alt,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Map panel
                  _sectionTitle('Satellite map and analysis area'),
                  const SizedBox(height: 10),
                  MapPanel(
                    initialCamera: _kGooglePlex,
                    mapType: _currentMapType,
                    onMapCreated: _onMapCreated,
                    onSelectRegion: _selectRegion,
                    onRunAnalysis: _runAnalysis,
                    onToggleMapType: () => setState(
                      () => _currentMapType = _currentMapType == MapType.hybrid
                          ? MapType.normal
                          : MapType.hybrid,
                    ),
                    selectedRegionLabel: _selectedRegion,
                    cropMasks: _cropMasks,
                  ),
                  const SizedBox(height: 18),

                  // Quick actions + stats
                  StatsActions(
                    area: _calculatedArea,
                    changePercent: _changePercent,
                    confidence: _modelConfidence,
                    cloud: _cloudCoverage,
                    onSelectRegion: _selectRegion,
                    onSelectTime: _selectTime,
                    onRunAnalysis: _runAnalysis,
                  ),
                  const SizedBox(height: 18),

                  // Export
                  _sectionTitle('Report export'),
                  const SizedBox(height: 10),
                  ExportSection(onExport: _exportReport),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.green.shade900,
      ),
    );
  }
}

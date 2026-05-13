import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/header.dart';
import 'widgets/map_panel.dart';
import 'widgets/map_fullscreen_selector.dart';
import 'widgets/stats_actions.dart';
import 'widgets/export_section.dart';

import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  MapType _currentMapType = MapType.normal;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedRegion = 'Selected area: Central farm block';
  LatLng? _selectedLatLng;
  double _calculatedArea = 125.5;
  double _changePercent = 12.4;
  double _modelConfidence = 91.0;
  double _cloudCoverage = 18.0;
  Set<Polygon> _cropMasks = {};
  Set<Marker> _selectionMarkers = {};
  Uint8List? _segmentationImageBytes;
  String? _segmentationImageError;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  void _handleMenuAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected $action')));
  }

  Future<void> _selectRegion() async {
    final LatLng? selection = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapFullscreenSelector(
          initialCamera: _kGooglePlex,
          initialSelected: _selectedLatLng,
        ),
      ),
    );
    if (selection == null) return;
    setState(() {
      _selectedLatLng = selection;
      _kGooglePlex = CameraPosition(target: selection, zoom: 12);
      _selectedRegion =
          'Selected area: ${selection.latitude.toStringAsFixed(5)}, ${selection.longitude.toStringAsFixed(5)}';
      _selectionMarkers = {
        Marker(
          markerId: const MarkerId('selected_region'),
          position: selection,
        ),
      };
    });
    await _moveCamera(_kGooglePlex);
  }

  void _selectTime() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }
    final String startDate =
        '${_startDate.year.toString().padLeft(4, '0')}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
    final String endDate =
        '${_endDate.year.toString().padLeft(4, '0')}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';
    final double lat = _selectedLatLng!.latitude;
    final double lng = _selectedLatLng!.longitude;
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
    try {
      final service = SegmentationService();
      final result = await service.fetchSegmentation(
        lat,
        lng,
        startDate,
        endDate,
        5,
      );
      if (result['code'] == 200) {
        final SegmentationModel data = result['data'];
        setState(() {
          _calculatedArea = data.pixel_area_m2 * 0.0001;
          _changePercent = 10.5;
          _modelConfidence = 95.2;
          _cloudCoverage = data.cloud_cover;
        });
        _setSegmentationImage(data.segmentation_base64);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Segmentation analysis completed!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during analysis: $e')));
      debugPrint('Error during analysis: $e');
    }
  }

  void _exportReport(String format) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Exporting report as $format')));

  void _onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  Future<void> _moveCamera(CameraPosition position) async {
    if (!_controller.isCompleted) return;
    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void _setSegmentationImage(String? base64Image) {
    if (base64Image == null || base64Image.trim().isEmpty) {
      setState(() {
        _segmentationImageBytes = null;
        _segmentationImageError = 'Segmentation image is empty.';
      });
      return;
    }
    try {
      final String cleaned = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;
      final Uint8List bytes = base64Decode(cleaned);
      setState(() {
        _segmentationImageBytes = bytes;
        _segmentationImageError = null;
      });
    } catch (_) {
      setState(() {
        _segmentationImageBytes = null;
        _segmentationImageError = 'Invalid segmentation image data.';
      });
    }
  }

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
                    selectionMarkers: _selectionMarkers,
                  ),
                  const SizedBox(height: 18),

                  if (_segmentationImageBytes != null ||
                      _segmentationImageError != null) ...[
                    _sectionTitle('Segmentation preview'),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _legendItem(
                              color: const Color.fromARGB(255, 255, 255, 0),
                              label: 'agriculture',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 232, 184, 153),
                              label: 'barren',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 0, 255, 0),
                              label: 'forest',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 255, 0, 255),
                              label: 'rangeland',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              label: 'unknown',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 0, 255, 255),
                              label: 'urban',
                            ),
                            _legendItem(
                              color: const Color.fromARGB(255, 0, 0, 255),
                              label: 'water',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _segmentationImageBytes == null
                              ? Text(
                                  _segmentationImageError ??
                                      'No segmentation preview available.',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    _segmentationImageBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],

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

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:farmlens_app/presentation/home/widgets/actions_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/export_section.dart';
import 'package:farmlens_app/presentation/change_detection/widgets/comparison_panel.dart';
import 'package:farmlens_app/presentation/widgets/header.dart';
import 'package:farmlens_app/presentation/widgets/map_fullscreen_selector.dart';
import 'package:farmlens_app/presentation/widgets/map_panel.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChangeDetectionScreen extends StatefulWidget {
  const ChangeDetectionScreen({super.key});

  @override
  State<ChangeDetectionScreen> createState() => _ChangeDetectionScreenState();
}

class _ChangeDetectionScreenState extends State<ChangeDetectionScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>(); 

  final ComparisonService _comparisonService = ComparisonService();

  ComparisonModel? _comparisonResult;
  String? _comparisonError;

  MapType _currentMapType = MapType.normal;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedRegion = 'Selected area: Central farm block';
  LatLng? _selectedLatLng;
  Set<Marker> _selectionMarkers = {};

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );
  void _handleMenuAction(String action) {
    switch (action) {
      case 'Home':
        Navigator.of(context).pushNamed(AppRoutes.home);
        break;
      case 'Change Detection':
        Navigator.of(context).pushNamed(AppRoutes.changeDetection);
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Selected $action')));
    }
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

  void _onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  Future<void> _moveCamera(CameraPosition position) async {
    if (!_controller.isCompleted) return;
    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void _selectTime() async {
    final selectedDate = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate.start;
        _endDate = selectedDate.end;
      });
    }
  }

  Future<void> _runDetection() async {
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }
    final String date1 =
        '${_startDate.year.toString().padLeft(4, '0')}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
    final String date2 =
        '${_endDate.year.toString().padLeft(4, '0')}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';
    final double lat = _selectedLatLng!.latitude;
    final double lng = _selectedLatLng!.longitude;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running satellite segmentation pipeline...'),
      ),
    );
    try {
      setState(() {
        _comparisonResult = null;
        _comparisonError = null;
      });
      final result = await _comparisonService.fetchComparison(
        lat: lat,
        lng: lng,
        date1: date1,
        date2: date2,
        cloudCover: 20,
      );
      if (result['code'] == 200) {
        setState(() {
          _comparisonResult = result['data'] as ComparisonModel;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change detection results retrieved successfully!'),
          ),
        );
      } else {
        setState(() {
          _comparisonError = result['message']?.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: ${result['message']}')),
        );
      }
    } catch (e) {
      setState(() {
        _comparisonError = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during analysis: $e')));
      debugPrint('Error during analysis: $e');
    }
  }

  void _exportReport(String format) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Exporting report as $format')));


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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: HomeHeader(
                      onMenuSelected: _handleMenuAction,
                      title: 'FarmLens Change Detection',
                      subtitle:
                          'Monitor changes in your farm over time with precision and ease.',
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
                    onRunAnalysis: _runDetection,
                    onToggleMapType: () => setState(
                      () => _currentMapType = _currentMapType == MapType.hybrid
                          ? MapType.normal
                          : MapType.hybrid,
                    ),
                    selectedRegionLabel: _selectedRegion,
                    selectionMarkers: _selectionMarkers,
                  ),
                  const SizedBox(height: 18),

                  StatsActions(
                    onSelectRegion: _selectRegion,
                    onSelectTime: _selectTime,
                    onRunAnalysis: _runDetection,
                  ),
                  const SizedBox(height: 18),

                  ComparisonPanel(
                    result: _comparisonResult,
                    error: _comparisonError,
                  ),
                  if (_comparisonResult != null || _comparisonError != null)
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
}

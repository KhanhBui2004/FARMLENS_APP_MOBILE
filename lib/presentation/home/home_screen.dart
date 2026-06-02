import 'dart:async';

import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/presentation/home/widgets/chart_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/comparison_panel.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/header.dart';
import '../widgets/map_panel.dart';
import '../widgets/map_fullscreen_selector.dart';
import 'widgets/actions_panel.dart';
import 'widgets/export_section.dart';

import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final _statService = StatisticsService();
  final ComparisonService _comparisonService = ComparisonService();

  ComparisonModel? _comparisonResult;
  String? _comparisonError;

  StatisticsModel? _latestStats;

  final _authService = AuthService();

  MapType _currentMapType = MapType.normal;
  DateTime _firstDate = DateTime.now();
  DateTime _secondDate = DateTime.now();
  String _selectedRegion = 'Selected area: Central farm block';
  LatLng? _selectedLatLng;
  double _calculatedArea = 125.5;
  double _cloudCoverage = 18.0;
  Set<Marker> _selectionMarkers = {};
  String? _segmentationId;
  String? _segmentationImageUrl;
  String? _segmentationImageError;
  String? _sentinelImageUrl;
  String? _sentinelImageError;
  double _overlayOpacity = 0.5;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  void _handleMenuAction(String action) {
    switch (action) {
      case 'Home':
        Navigator.of(context).pushNamed(AppRoutes.home);
        break;
      case 'Logout':
        // Implement logout logic here
        _authService.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
        break;
      case 'History':
        Navigator.of(context).pushNamed(AppRoutes.history);
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Selected $action')));
    }
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

  void _selectFirstTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _firstDate,
    );
    if (selectedDate != null) {
      setState(() {
        _firstDate = selectedDate;
      });
    }
  }

  void _selectSecondTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _secondDate,
    );
    if (selectedDate != null) {
      setState(() {
        _secondDate = selectedDate;
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
    final String date =
        '${_firstDate.year.toString().padLeft(4, '0')}-${_firstDate.month.toString().padLeft(2, '0')}-${_firstDate.day.toString().padLeft(2, '0')}';
    final double lat = _selectedLatLng!.latitude;
    final double lng = _selectedLatLng!.longitude;

    setState(() {
      _latestStats = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running satellite segmentation pipeline...'),
      ),
    );
    try {
      final service = SegmentationService();
      final result = await service.fetchSegmentation(lat, lng, date, 5);
      if (result['code'] == 200) {
        final SegmentationModel data = result['data'];
        setState(() {
          _calculatedArea = data.pixel_area_m2 * 0.0001;
          _cloudCoverage = data.cloud_cover;
        });
        _segmentationId = data.id;
        _setSegmentationImage(data.segmentation_url);
        _setSentinelImage(data.sentinel_image_url);
        if (_segmentationId != null && _segmentationId!.isNotEmpty) {
          await _statistic();
        }
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

  Future<void> _statistic() async {
    if (_segmentationId == null || _segmentationId!.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetching statistics data...')),
    );
    try {
      // Implement statistics fetching logic here
      final result = await _statService.fetchStatistics(
        analysisId: _segmentationId,
      );
      if (result['code'] == 200) {
        final StatisticsModel data = result['data'];
        setState(() {
          _latestStats = data;
        });
        debugPrint('Statistics data: ${data.toString()}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch statistics: ${result['message']}'),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statistics data fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching statistics: $e')));
      debugPrint('Error fetching statistics: $e');
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
        '${_firstDate.year.toString().padLeft(4, '0')}-${_firstDate.month.toString().padLeft(2, '0')}-${_firstDate.day.toString().padLeft(2, '0')}';
    final String date2 =
        '${_secondDate.year.toString().padLeft(4, '0')}-${_secondDate.month.toString().padLeft(2, '0')}-${_secondDate.day.toString().padLeft(2, '0')}';
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

  void _onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  Future<void> _moveCamera(CameraPosition position) async {
    if (!_controller.isCompleted) return;
    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void _setSegmentationImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      setState(() {
        _segmentationImageUrl = null;
        _segmentationImageError = 'Segmentation image is empty.';
      });
      return;
    }
    final String normalized = imageUrl.startsWith('http')
        ? imageUrl
        : imageUrl.startsWith('/')
        ? '${ApiEndpoints.baseUrl}$imageUrl'
        : '${ApiEndpoints.baseUrl}/$imageUrl';
    setState(() {
      _segmentationImageUrl = normalized;
      _segmentationImageError = null;
    });
  }

  void _setSentinelImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      setState(() {
        _sentinelImageUrl = null;
        _sentinelImageError = 'Sentinel image is empty.';
      });
      return;
    }
    final String normalized = imageUrl.startsWith('http')
        ? imageUrl
        : imageUrl.startsWith('/')
        ? '${ApiEndpoints.baseUrl}$imageUrl'
        : '${ApiEndpoints.baseUrl}/$imageUrl';
    setState(() {
      _sentinelImageUrl = normalized;
      _sentinelImageError = null;
    });
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
                    // onRunAnalysis: _runAnalysis,
                    onToggleMapType: () => setState(
                      () => _currentMapType = _currentMapType == MapType.hybrid
                          ? MapType.normal
                          : MapType.hybrid,
                    ),
                    selectedRegionLabel: _selectedRegion,
                    selectionMarkers: _selectionMarkers,
                  ),
                  const SizedBox(height: 18),

                  // Quick actions + stats
                  StatsActions(
                    onSelectFirstTime: _selectFirstTime,
                    onSelectSecondTime: _selectSecondTime,
                    onRunAnalysis: _runAnalysis,
                    onChangeDetection: _runDetection,
                  ),
                  const SizedBox(height: 18),

                  if (_segmentationImageUrl != null ||
                      _segmentationImageError != null) ...[
                    _sectionTitle('Segmentation preview'),
                    const SizedBox(height: 10),
                    Column(
                      children: [
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
                          child: _sentinelImageUrl == null
                              ? Text(
                                  _sentinelImageError ??
                                      'No sentinel preview available.',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.network(
                                            _sentinelImageUrl!,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Text(
                                                    'Unable to load sentinel image.',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  );
                                                },
                                          ),

                                          if (_segmentationImageUrl != null)
                                            Opacity(
                                              opacity: _overlayOpacity,
                                              child: Image.network(
                                                _segmentationImageUrl!,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const SizedBox.shrink();
                                                    },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    if (_segmentationImageUrl != null) ...[
                                      Text(
                                        'Segmentation overlay: ${(_overlayOpacity * 100).round()}%',
                                      ),
                                      Slider(
                                        value: _overlayOpacity,
                                        min: 0,
                                        max: 1,
                                        divisions: 100,
                                        label:
                                            '${(_overlayOpacity * 100).round()}%',
                                        onChanged: (value) {
                                          setState(() {
                                            _overlayOpacity = value;
                                          });
                                        },
                                      ),
                                    ] else
                                      Text(
                                        _segmentationImageError ??
                                            'No segmentation preview available.',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
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
                        const SizedBox(height: 18),

                        ChartPanel(latestStats: _latestStats),
                      ],
                    ),

                    const SizedBox(height: 18),
                  ],
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

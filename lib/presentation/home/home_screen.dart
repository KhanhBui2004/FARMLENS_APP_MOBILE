import 'dart:async';
import 'dart:math' as math;

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/presentation/home/widgets/chart_panel.dart';
import 'package:farmlens_app/presentation/home/widgets/comparison_panel.dart';
import 'package:farmlens_app/data/services/export/report_export_service.dart';
import 'package:farmlens_app/presentation/home/widgets/stats_panel.dart';
import 'package:farmlens_app/presentation/widgets/current_area_assessment_panel.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/header.dart';
import '../widgets/map_panel.dart';
import '../widgets/map_fullscreen_selector.dart';
import 'widgets/actions_panel.dart';
import 'widgets/export_section.dart';

import 'package:printing/printing.dart';

import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
import 'package:farmlens_app/presentation/widgets/recommendation_panel.dart';

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
  final _reportExportService = ReportExportService();

  ComparisonModel? _comparisonResult;
  String? _comparisonError;

  StatisticsModel? _latestStats;

  final _authService = AuthService();

  MapType _currentMapType = MapType.normal;
  DateTime _firstDate = DateTime.now();
  DateTime _secondDate = DateTime.now();
  String _selectedRegion = 'Khu vực đã chọn: chưa có';
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
  bool _isloading = false;
  String _loadingMessage = 'Đang xử lý...';

  DateTime? _segmentationAnalysisDate;
  LatLng? _segmentationLatLng;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  void _handleMenuAction(String action) {
    switch (action) {
      case 'Logout':
        _authService.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Đăng xuất thành công!',
          type: ContentType.success,
        );
        break;
      case 'History':
        Navigator.of(context).pushNamed(AppRoutes.history);
        break;
      case 'Profile':
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  void _showLoading(String message) {
    setState(() {
      _isloading = true;
      _loadingMessage = message;
    });
  }

  void _hideLoading() {
    if (!mounted) return;
    setState(() => _isloading = false);
  }

  void showAwesomeSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType type,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
          'Khu vực đã chọn: ${selection.latitude.toStringAsFixed(5)}, ${selection.longitude.toStringAsFixed(5)}';

      _selectionMarkers = {
        Marker(
          markerId: const MarkerId('selected_region'),
          position: selection,
        ),
      };

      // Clear kết quả cũ vì đã đổi vùng
      _latestStats = null;
      _segmentationId = null;
      _segmentationImageUrl = null;
      _segmentationImageError = null;
      _sentinelImageUrl = null;
      _sentinelImageError = null;

      _comparisonResult = null;
      _comparisonError = null;
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
        const SnackBar(content: Text('Vui lòng chọn một vị trí trên bản đồ.')),
      );
      return;
    }
    final String date =
        '${_firstDate.year.toString().padLeft(4, '0')}-${_firstDate.month.toString().padLeft(2, '0')}-${_firstDate.day.toString().padLeft(2, '0')}';
    final double lat = _selectedLatLng!.latitude;
    final double lng = _selectedLatLng!.longitude;

    setState(() {
      _latestStats = null;
      _segmentationId = null;
      _segmentationImageUrl = null;
      _segmentationImageError = null;
      _sentinelImageUrl = null;
      _sentinelImageError = null;

      _comparisonResult = null;
      _comparisonError = null;
    });

    _showLoading('Đang phân đoạn...');

    try {
      final service = SegmentationService();
      final result = await service.fetchSegmentation(lat, lng, date, 20);

      if (!mounted) return;

      if (result['code'] == 200) {
        final SegmentationModel data = result['data'];
        setState(() {
          _segmentationAnalysisDate = _firstDate;
          _segmentationLatLng = LatLng(lat, lng);

          _calculatedArea = data.regionAreaM2 / 1000000;
          _cloudCoverage = data.cloudCover;
        });
        _segmentationId = data.id;
        _setSegmentationImage(data.segmentationUrl);
        _setSentinelImage(data.sentinelImageUrl);
        if (_segmentationId != null && _segmentationId!.isNotEmpty) {
          await _statistic();
        }

        if (!mounted) return;

        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Phân đoạn hoàn tất thành công!',
          type: ContentType.success,
        );
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: 'Phân tích thất bại: ${result['message']}',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Lỗi trong quá trình phân tích: $e',
        type: ContentType.failure,
      );
      debugPrint('Error during analysis: $e');
    } finally {
      _hideLoading();
    }
  }

  Future<void> _statistic() async {
    if (_segmentationId == null || _segmentationId!.isEmpty) {
      return;
    }
    try {
      // Implement statistics fetching logic here
      final result = await _statService.fetchStatistics(
        analysisId: _segmentationId,
      );

      if (!mounted) return;

      if (result['code'] == 200) {
        final StatisticsModel data = result['data'];
        setState(() {
          _latestStats = data;
        });
        debugPrint('Statistics data: ${data.toString()}');
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: 'Lỗi thống kê: ${result['message']}',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Lỗi thống kê: $e',
        type: ContentType.failure,
      );
      debugPrint('Error fetching statistics: $e');
    }
  }

  Future<void> _runDetection() async {
    if (_selectedLatLng == null) {
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Vui lòng chọn một vị trí trên bản đồ.',
        type: ContentType.failure,
      );
      return;
    }

    if (_firstDate.year == _secondDate.year &&
        _firstDate.month == _secondDate.month &&
        _firstDate.day == _secondDate.day) {
      showAwesomeSnackBar(
        context: context,
        title: 'Thời gian không hợp lệ',
        message: 'Vui lòng chọn hai ngày khác nhau để phát hiện thay đổi.',
        type: ContentType.warning,
      );
      return;
    }

    final String date1 =
        '${_firstDate.year.toString().padLeft(4, '0')}-${_firstDate.month.toString().padLeft(2, '0')}-${_firstDate.day.toString().padLeft(2, '0')}';
    final String date2 =
        '${_secondDate.year.toString().padLeft(4, '0')}-${_secondDate.month.toString().padLeft(2, '0')}-${_secondDate.day.toString().padLeft(2, '0')}';
    final double lat = _selectedLatLng!.latitude;
    final double lng = _selectedLatLng!.longitude;

    _showLoading('Đang phát hiện biến động...');

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

      if (!mounted) return;

      if (result['code'] == 200) {
        setState(() {
          _comparisonResult = result['data'] as ComparisonModel;
        });
        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Phát hiện thay đổi hoàn tất thành công!',
          type: ContentType.success,
        );
      } else {
        setState(() {
          _comparisonError = result['message']?.toString();
        });
        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: 'Phân tích thất bại: ${result['message']}',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      setState(() {
        _comparisonError = e.toString();
      });
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Lỗi trong quá trình phân tích: $e',
        type: ContentType.failure,
      );
      debugPrint('Error during analysis: $e');
    } finally {
      _hideLoading();
    }
  }

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
        _segmentationImageError = 'Ảnh phân đoạn không khả dụng.';
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
        _sentinelImageError = 'Ảnh sentinel không khả dụng.';
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

  Future<void> _exportReport(String format) async {
    if (_latestStats == null) {
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Vui lòng chạy phân tích phân đoạn trước khi xuất báo cáo.',
        type: ContentType.failure,
      );
      return;
    }

    if (format.toLowerCase() != 'pdf') {
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Hiện chỉ hỗ trợ xuất báo cáo PDF.',
        type: ContentType.failure,
      );
      return;
    }

    try {
      _showLoading('Đang tạo báo cáo PDF...');

      final pdfBytes = await _reportExportService.buildPdfReport(
        stats: _latestStats!,
        segmentationId: _segmentationId,
        analysisDate: _segmentationAnalysisDate ?? _firstDate,
        lat: _segmentationLatLng?.latitude,
        lng: _segmentationLatLng?.longitude,
        cloudCoverage: _cloudCoverage,
        calculatedArea: _calculatedArea,
        sentinelImageUrl: _sentinelImageUrl,
        segmentationImageUrl: _segmentationImageUrl,
        comparisonResult: _comparisonResult,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'farmlens_report.pdf',
      );

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: 'Lỗi khi xuất báo cáo: $e',
        type: ContentType.failure,
      );
    } finally {
      if (mounted) _hideLoading();
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: HomeHeader(
                    onMenuSelected: _handleMenuAction,
                    title: 'Bảng điều khiển FarmLens',
                    subtitle: 'Phân tích nông nghiệp từ ảnh vệ tinh',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header

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
                                      'Tổng quan hoạt động',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Phân tích nông nghiệp từ hình ảnh vệ tinh',
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
                        _sectionTitle('Bản đồ vệ tinh '),
                        const SizedBox(height: 10),
                        MapPanel(
                          initialCamera: _kGooglePlex,
                          mapType: _currentMapType,
                          onMapCreated: _onMapCreated,
                          onSelectRegion: _selectRegion,
                          // onRunAnalysis: _runAnalysis,
                          onToggleMapType: () => setState(
                            () => _currentMapType =
                                _currentMapType == MapType.hybrid
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

                        if (_latestStats?.currentAreaAssessment != null) ...[
                          CurrentAreaAssessmentPanel(
                            assessment: _latestStats!.currentAreaAssessment,
                          ),
                          const SizedBox(height: 18),
                        ],

                        if (_latestStats != null) ...[
                          StatsPanel(
                            stats: _latestStats,
                            comparison: _comparisonResult,
                            cloud: _cloudCoverage,
                          ),
                          const SizedBox(height: 18),
                        ],

                        if (_segmentationImageUrl != null ||
                            _segmentationImageError != null) ...[
                          _sectionTitle('Kết quả phân đoạn'),
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
                                            'Không có ảnh sentinel để hiển thị.',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child:
                                                _buildSegmentationOverlayImage(),
                                          ),

                                          const SizedBox(height: 12),

                                          if (_segmentationImageUrl !=
                                              null) ...[
                                            Text(
                                              'Độ mờ: ${(_overlayOpacity * 100).round()}%',
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
                                                  'Không có ảnh phân đoạn để hiển thị.',
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _legendItem(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      100,
                                    ),
                                    label: 'Đất nông nghiệp',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(
                                      255,
                                      210,
                                      180,
                                      140,
                                    ),
                                    label: 'Đất trống',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(255, 0, 100, 0),
                                    label: 'Rừng',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(
                                      255,
                                      124,
                                      252,
                                      0,
                                    ),
                                    label: 'Đồng cỏ',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    label: 'Không xác định',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(
                                      255,
                                      178,
                                      34,
                                      34,
                                    ),
                                    label: 'Đô thị',
                                  ),
                                  _legendItem(
                                    color: const Color.fromARGB(
                                      255,
                                      65,
                                      105,
                                      225,
                                    ),
                                    label: 'Nước',
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
                        if (_comparisonResult != null ||
                            _comparisonError != null)
                          const SizedBox(height: 18),
                        RecommendationPanel(result: _comparisonResult),
                        const SizedBox(height: 18),
                        // Export
                        if (_latestStats != null) ...[
                          _sectionTitle('Xuất báo cáo'),
                          const SizedBox(height: 10),
                          // ExportSection(onExport: _exportReport),
                          ExportSection(
                            onExport: _exportReport,
                            canExport: _latestStats != null,
                            isExporting: _isloading,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isloading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  Widget _buildSegmentationOverlayImage() {
  final survey = _latestStats?.surveyRegion;

  final imageWidth = _latestStats?.imageSize.width.toDouble() ?? 1024.0;
  final imageHeight = _latestStats?.imageSize.height.toDouble() ?? 1024.0;

  final aspectRatio = imageWidth / imageHeight;

  return AspectRatio(
    aspectRatio: aspectRatio,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final markerXRatio = survey?.markerXRatio ?? survey?.centerXRatio;
        final markerYRatio = survey?.markerYRatio ?? survey?.centerYRatio;

        final hasSurveyMarker = survey != null &&
            survey.available &&
            markerXRatio != null &&
            markerYRatio != null;

        final markerX = hasSurveyMarker ? markerXRatio * width : 0.0;
        final markerY = hasSurveyMarker ? markerYRatio * height : 0.0;

        final labelLeft = hasSurveyMarker
            ? math.max(8.0, math.min(width - 100.0, markerX - 50.0))
            : 0.0;

        final labelTop = hasSurveyMarker
            ? math.max(8.0, markerY - 38.0)
            : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.network(
                _sentinelImageUrl!,
                fit: BoxFit.fill,
              ),
            ),

            if (_segmentationImageUrl != null)
              Positioned.fill(
                child: Opacity(
                  opacity: _overlayOpacity,
                  child: Image.network(
                    _segmentationImageUrl!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

            if (hasSurveyMarker) ...[
              Positioned(
                left: labelLeft,
                top: labelTop,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '${survey.areaKm2.toStringAsFixed(2)} km²',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ),

              // Điểm chính xác nằm trong cụm agriculture lớn nhất
              Positioned(
                left: markerX - 7,
                top: markerY - 7,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    ),
  );
}

  Widget _surveyMarker({required double areaKm2}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${areaKm2.toStringAsFixed(2)} km²',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Icon(Icons.location_on, color: Color(0xFF1B5E20), size: 38),
      ],
    );
  }
}

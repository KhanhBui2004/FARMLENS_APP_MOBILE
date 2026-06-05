import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/presentation/history/widgets/change_detection_list.dart';
import 'package:farmlens_app/presentation/history/widgets/comparison_details_sheet.dart';
import 'package:farmlens_app/presentation/history/widgets/history_tab_selector.dart';
import 'package:farmlens_app/presentation/history/widgets/segmentation_details_sheet.dart';
import 'package:farmlens_app/presentation/history/widgets/segmentation_list.dart';
import 'package:farmlens_app/presentation/widgets/header.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authService = AuthService();
  final _segmentationService = SegmentationService();
  final _statisticsService = StatisticsService();
  final _comparisonService = ComparisonService();

  List<SegmentationModel> _segmentationData = [];
  List<ComparisonModel> _changeDetectionData = [];
  StatisticsModel? _statisticsData;
  bool _isSegmentationTab = true;
  bool _isLoading = false;
  String _loadingMessage = 'Processing...';

  @override
  void initState() {
    super.initState();
    _fetchSegmentationData();
    _fetchChangeDetectionData();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'Home':
        Navigator.of(context).pushNamed(AppRoutes.home);
        break;
      case 'Logout':
        _authService.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'Logged out successfully!',
          type: ContentType.success,
        );
        break;
      case 'Profile':
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  void _showLoading([String? message]) {
    setState(() {
      _isLoading = true;
      if (message != null) {
        _loadingMessage = message;
      }
    });
  }

  void _hideLoading() {
    setState(() => _isLoading = false);
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

  Future<void> _fetchSegmentationData() async {
    try {
      final result = await _segmentationService.fetchSegmentationByUser();

      if (!mounted) return;

      if (result['code'] == 200) {
        debugPrint('Segmentation data fetched successfully!');

        _segmentationData = result['data'];
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to fetch segmentation data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _deleteSegmentationData() async {
    try {
      _showLoading('Deleting segmentation data...');

      final result = await _segmentationService.deleteAllSegmentation();

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'Segmentation data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _segmentationData.clear();
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to delete segmentation data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    } finally {
      _hideLoading();
    }
  }

  Future<void> _deleteSegmentationById(String segmentationId) async {
    try {
      final result = await _segmentationService.deleteSegmentationById(
        segmentationId,
      );

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'Segmentation data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _segmentationData.removeWhere((item) => item.id == segmentationId);
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to delete segmentation data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _confirmDeleteSegmentationById(SegmentationModel item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete segmentation'),
          content: Text(
            'Are you sure you want to delete Analysis ${_segmentationData.indexOf(item) + 1}?\n\nID: ${item.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteSegmentationById(item.id);
      await _deleteStatisticsById(item.id);
    }
  }

  Future<void> _confirmDeleteAllSegmentation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete all history'),
          content: const Text(
            'Are you sure you want to delete all segmentation history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteSegmentationData();
      await _deleteAllStatistics();
    }
  }

  Future<StatisticsModel?> _fetchStatisticsData(String analysisId) async {
    try {
      final result = await _statisticsService.fetchStatisticsById(analysisId);

      if (!mounted) return null;

      if (result['code'] == 200) {
        debugPrint('Statistics data fetched successfully!');
        _statisticsData = result['data'];
        return result['data'] as StatisticsModel;
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to fetch statistics data',
          type: ContentType.failure,
        );
        return null;
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
      return null;
    }
  }

  Future<void> _deleteAllStatistics() async {
    try {
      _showLoading('Deleting statistics data...');
      final result = await _statisticsService.deleteAllStatistics();

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'All statistics data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _statisticsData = null;
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to delete statistics data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    } finally {
      _hideLoading();
    }
  }

  Future<void> _deleteStatisticsById(String analysisId) async {
    try {
      final result = await _statisticsService.deleteStatisticsById(analysisId);

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'Statistics data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _statisticsData = null;
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to delete statistics data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _fetchChangeDetectionData() async {
    try {
      final result = await _comparisonService.fetchComparisonByUser();

      if (!mounted) return;

      if (result['code'] == 200) {
        debugPrint('Change detection data fetched successfully!');

        _changeDetectionData = result['data'];
        setState(() {});
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message: result['message'] ?? 'Failed to fetch change detection data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _deleteChangeDetectionById(String analysisId) async {
    try {
      final result = await _comparisonService.deleteComparisonById(analysisId);

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'Change detection data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _changeDetectionData.removeWhere((item) => item.id == analysisId);
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message:
              result['message'] ?? 'Failed to delete change detection data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _deleteAllChangeDetection() async {
    try {
      final result = await _comparisonService.deleteAllComparisons();

      if (!mounted) return;

      if (result['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Success',
          message: 'All change detection data deleted successfully!',
          type: ContentType.success,
        );
        setState(() {
          _changeDetectionData.clear();
        });
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Error',
          message:
              result['message'] ?? 'Failed to delete change detection data',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Error',
        message: e.toString(),
        type: ContentType.failure,
      );
    }
  }

  Future<void> _confirmDeleteChangeDetectionById(ComparisonModel item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete change detection'),
          content: Text(
            'Are you sure you want to delete Change Detection ${_changeDetectionData.indexOf(item) + 1}?\n\nID: ${item.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteChangeDetectionById(item.id);
    }
  }

  Future<void> _confirmDeleteAllChangeDetection() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete all history'),
          content: const Text(
            'Are you sure you want to delete all change detection history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAllChangeDetection();
    }
  }

  void _showSegmentationDetails(SegmentationModel item) {
    final statisticsFuture = _fetchStatisticsData(item.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SegmentationDetailsSheet(
          item: item,
          statisticsFuture: statisticsFuture,
        );
      },
    );
  }

  void _showComparisonDetails(ComparisonModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ComparisonDetailsSheet(item: item);
      },
    );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: HomeHeader(
                      onMenuSelected: _handleMenuAction,
                      title: 'Farmlens History',
                      subtitle:
                          'Monitor changes in your farm over time with precision and ease.',
                    ),
                  ),
                  const SizedBox(height: 18),
                  HistoryTabSelector(
                    isSegmentationTab: _isSegmentationTab,
                    onSegmentationTap: () =>
                        setState(() => _isSegmentationTab = true),
                    onChangeDetectionTap: () =>
                        setState(() => _isSegmentationTab = false),
                  ),
                  const SizedBox(height: 16),
                  if (_isSegmentationTab)
                    SegmentationList(
                      items: _segmentationData,
                      onDeleteAll: _confirmDeleteAllSegmentation,
                      onItemTap: _showSegmentationDetails,
                      onDeleteItem: _confirmDeleteSegmentationById,
                    )
                  else
                    ChangeDetectionList(
                      items: _changeDetectionData,
                      onDeleteAll: _confirmDeleteAllChangeDetection,
                      onItemTap: _showComparisonDetails,
                      onDeleteItem: _confirmDeleteChangeDetectionById,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

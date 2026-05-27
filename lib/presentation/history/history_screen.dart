import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/services/analysis/comparison_service.dart';
import 'package:farmlens_app/data/services/analysis/overlay_service.dart';
import 'package:farmlens_app/data/services/analysis/segmentation_service.dart';
import 'package:farmlens_app/data/services/analysis/statistics_service.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
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
  final _overlayService = OverlayService();
  final _segmentationService = SegmentationService();
  final _statisticsService = StatisticsService();
  final _comparisonService = ComparisonService();

  List<SegmentationModel> _segmentationData = [];
  List<ComparisonModel> _changeDetectionData = [];
  StatisticsModel? _statisticsData;
  bool _isSegmentationTab = true;

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

  Future<void> _fetchSegmentationData() async {
    try {
      final result = await _segmentationService.fetchSegmentationByUser();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Segmentation data fetched successfully!'),
          ),
        );

        _segmentationData = result['data'];

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to fetch segmentation data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteSegmentationData() async {
    try {
      final result = await _segmentationService.deleteAllSegmentation();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Segmentation data deleted successfully!'),
          ),
        );
        // _fetchSegmentationData(); // Refresh the list after deletion
        setState(() {
          _segmentationData.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete segmentation data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteSegmentationById(String segmentationId) async {
    try {
      final result = await _segmentationService.deleteSegmentationById(
        segmentationId,
      );
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Segmentation data deleted successfully!'),
          ),
        );
        setState(() {
          _segmentationData.removeWhere((item) => item.id == segmentationId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete segmentation data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
      await _deleteAllOverlayData();
      await _deleteAllStatistics();
    }
  }

  Future<void> _fetchStatisticsData(String analysisId) async {
    try {
      final result = await _statisticsService.fetchStatisticsById(analysisId);
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statistics data fetched successfully!'),
          ),
        );
        _statisticsData = result['data'];
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to fetch statistics data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteAllStatistics() async {
    try {
      final result = await _statisticsService.deleteAllStatistics();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All statistics data deleted successfully!'),
          ),
        );
        setState(() {
          _statisticsData = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete statistics data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteStatisticsById(String analysisId) async {
    try {
      final result = await _statisticsService.deleteStatisticsById(analysisId);
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statistics data deleted successfully!'),
          ),
        );
        setState(() {
          _statisticsData = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete statistics data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _fetchChangeDetectionData() async {
    try {
      final result = await _comparisonService.fetchComparisonByUser();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change detection data fetched successfully!'),
          ),
        );
        _changeDetectionData = result['data'];
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to fetch change detection data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteChangeDetectionById(String analysisId) async {
    try {
      final result = await _comparisonService.deleteComparisonById(analysisId);
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change detection data deleted successfully!'),
          ),
        );
        setState(() {
          _changeDetectionData.removeWhere((item) => item.id == analysisId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete change detection data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteAllChangeDetection() async {
    try {
      final result = await _comparisonService.deleteAllComparisons();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All change detection data deleted successfully!'),
          ),
        );
        setState(() {
          _changeDetectionData.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to delete change detection data',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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

  Future<void> _fetchOverlayData(String analysisId) async {
    try {
      final result = await _overlayService.fetchOverlay(analysisId);
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Overlay data fetched successfully!')),
        );
        // Handle the fetched overlay data as needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to fetch overlay data'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteOverlayData(String analysisId) async {
    try {
      final result = await _overlayService.deleteOverlay(analysisId);
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Overlay data deleted successfully!')),
        );
        // Optionally refresh the list or update the UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete overlay data'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteAllOverlayData() async {
    try {
      final result = await _overlayService.deleteAllOverlay();
      if (result['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All overlay data deleted successfully!'),
          ),
        );
        // Optionally refresh the list or update the UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete overlay data'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Segmentation list',
              isActive: _isSegmentationTab,
              onTap: () => setState(() => _isSegmentationTab = true),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              label: 'Change detection list',
              isActive: !_isSegmentationTab,
              onTap: () => setState(() => _isSegmentationTab = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? const Color(0xFF3F8E5A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF2B4A32),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentationList() {
    if (_segmentationData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No segmentation history yet.'),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF3F8E5A)),
                  SizedBox(width: 8),
                  Text(
                    'Your History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B4A32),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _confirmDeleteAllSegmentation,
              child: const Text(
                'Delete all',
                style: TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _segmentationData.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _segmentationData[index];
            return _buildCard(
              title: 'Analysis ${index + 1}',
              subtitle: 'Date: ${item.date}',
              lines: [
                'Cloud cover: ${item.cloud_cover.toStringAsFixed(1)}%',
                'Area: ${item.pixel_area_m2.toStringAsFixed(2)} m2',
                'Location: ${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
              ],
              onTap: () {
                _fetchStatisticsData(item.id);
                _fetchOverlayData(item.id);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChangeDetectionList() {
    if (_changeDetectionData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('No change detection history yet.'),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF3F8E5A)),
                  SizedBox(width: 8),
                  Text(
                    'Your History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B4A32),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _confirmDeleteAllChangeDetection,
              child: Text(
                'Delete all',
                style: TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _changeDetectionData.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _changeDetectionData[index];
            final dateRange = item.dates.isNotEmpty
                ? '${item.dates.first} -> ${item.dates.last}'
                : 'No dates';
            return _buildCard(
              title: 'Change detection ${index + 1}',
              subtitle: 'Created: ${item.created_at}',
              lines: [
                'Dates: $dateRange',
                'Cloud cover: ${item.cloud_cover.toStringAsFixed(1)}%',
                'Timeline items: ${item.timeline.length}',
                'Location: ${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required List<String> lines,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF4A6B57),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ...lines.map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    text,
                    style: const TextStyle(color: Color(0xFF2F4F3D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                  _buildTabSelector(),
                  const SizedBox(height: 16),
                  if (_isSegmentationTab)
                    _buildSegmentationList()
                  else
                    _buildChangeDetectionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

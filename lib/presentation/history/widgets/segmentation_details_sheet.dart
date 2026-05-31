import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:flutter/material.dart';

class SegmentationDetailsSheet extends StatelessWidget {
  final SegmentationModel item;
  final Future<StatisticsModel?> statisticsFuture;

  const SegmentationDetailsSheet({
    super.key,
    required this.item,
    required this.statisticsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: FutureBuilder<StatisticsModel?>(
          future: statisticsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const Text(
                    'Segmentation details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F3B2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow('Analysis ID', item.id),
                  _DetailRow('Date', item.date),
                  _DetailRow(
                    'Location',
                    '${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
                  ),
                  _DetailRow(
                    'Cloud cover',
                    '${item.cloud_cover.toStringAsFixed(1)}%',
                  ),
                  _DetailRow(
                    'Pixel area',
                    '${item.pixel_area_m2.toStringAsFixed(2)} m2',
                  ),
                  _DetailRow('Sentinel image', item.sentinel_image_url),
                  _DetailRow('Segmentation image', item.segmentation_url),
                  const SizedBox(height: 16),
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F3B2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (stats == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No statistics available for this analysis.',
                        style: TextStyle(color: Color(0xFF4A6B57)),
                      ),
                    )
                  else ...[
                    _DetailRow('Created at', stats.createdAt),
                    _DetailRow(
                      'Image size',
                      '${stats.imageSize.width} x ${stats.imageSize.height}',
                    ),
                    _DetailRow(
                      'Total pixels',
                      stats.imageSize.total_pixels.toString(),
                    ),
                    _DetailRow(
                      'Unmatched pixels',
                      stats.imageSize.unmatched_pixels.toString(),
                    ),
                    _DetailRow(
                      'Pixel area',
                      '${stats.imageSize.pixel_area_m2.toStringAsFixed(2)} m2',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Land cover classes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F3B2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ClassRow('Agriculture', stats.classes.agriculture),
                    _ClassRow('Barren', stats.classes.barren),
                    _ClassRow('Forest', stats.classes.forest),
                    _ClassRow('Rangeland', stats.classes.rangeland),
                    _ClassRow('Urban', stats.classes.urban),
                    _ClassRow('Water', stats.classes.water),
                    _ClassRow('Unknown', stats.classes.unknown),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A6B57),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F3B2D)),
          ),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final String label;
  final ClassStatsModel? stats;

  const _ClassRow(this.label, this.stats);

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FBF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0EEE4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F3B2D),
                ),
              ),
            ),
            Text(
              '${stats!.percentage.toStringAsFixed(2)}%',
              style: const TextStyle(color: Color(0xFF2F4F3D)),
            ),
            const SizedBox(width: 12),
            Text(
              '${stats!.area_km2.toStringAsFixed(3)} km2',
              style: const TextStyle(color: Color(0xFF2F4F3D)),
            ),
          ],
        ),
      ),
    );
  }
}

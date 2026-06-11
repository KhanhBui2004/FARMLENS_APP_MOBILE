import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/utils/constant/api_endpoints.dart';
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
                  _DetailRow('Segmentation Date', item.date),
                  _DetailRow(
                    'Location',
                    '${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
                  ),
                  _DetailRow(
                    'Cloud cover',
                    '${item.cloudCover.toStringAsFixed(1)}%',
                  ),
                  Text(
                    'Sentinel image',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A6B57),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      '${ApiEndpoints.baseUrl}${item.sentinelImageUrl}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Unable to load sentinel image.',
                          style: TextStyle(color: Colors.redAccent),
                        );
                      },
                    ),
                  ),
                  Text(
                    'Segmentation image',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A6B57),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      '${ApiEndpoints.baseUrl}${item.segmentationUrl}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Unable to load segmentation image.',
                          style: TextStyle(color: Colors.redAccent),
                        );
                      },
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
                  const SizedBox(height: 16),
                  const Text(
                    'Land cover statistics',
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
              '${stats!.area_km2.toStringAsFixed(3)} km²',
              style: const TextStyle(color: Color(0xFF2F4F3D)),
            ),
          ],
        ),
      ),
    );
  }
}

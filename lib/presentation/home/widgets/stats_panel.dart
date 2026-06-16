import 'package:flutter/material.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';

class StatsPanel extends StatelessWidget {
  final StatisticsModel? stats;
  final ComparisonModel? comparison;
  final double cloud;

  const StatsPanel({
    super.key,
    required this.stats,
    required this.comparison,
    required this.cloud,
  });

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String caption,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Text(
                  caption,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox.shrink();

    final agri = stats!.classes.agriculture;
    final cropAreaKm2 = (agri?.area_km2 ?? 0).toStringAsFixed(2);

    final change = comparison?.farmlandTracking?.agricultureRelativeChangePercentage ?? 0.0;
    final changeText =
        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

    final cropPercentage = agri?.percentage ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              title: 'Crop area',
              value: '$cropAreaKm2 km²',
              icon: Icons.square_foot,
              color: const Color(0xFF2E7D32),
              caption: '${cropPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(width: 12),
            _statCard(
              title: 'Change vs. last period',
              value: changeText,
              icon: Icons.trending_up,
              color: change < 0 ? const Color(0xFFC62828) : const Color(0xFF1565C0),
              caption: 'trend',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              title: 'Farmland share',
              value: '${cropPercentage.toStringAsFixed(1)}%',
              icon: Icons.agriculture,
              color: const Color(0xFFF57C00),
              caption: 'current',
            ),
            const SizedBox(width: 12),
            _statCard(
              title: 'Cloud coverage',
              value: '${cloud.toStringAsFixed(1)}%',
              icon: Icons.cloud,
              color: const Color(0xFF5E35B1),
              caption: 'image quality',
            ),
          ],
        ),
      ],
    );
  }
}
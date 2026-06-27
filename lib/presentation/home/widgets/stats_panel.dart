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

    final change =
        comparison?.farmlandTracking?.agricultureRelativeChangePercentage ??
        0.0;
    final changeText = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';

    final cropPercentage = agri?.percentage ?? 0.0;

    final survey = stats!.surveyRegion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan phân tích',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              title: 'Diện tích đất nông nghiệp',
              value: '$cropAreaKm2 km²',
              icon: Icons.square_foot,
              color: const Color(0xFF2E7D32),
              caption: '${cropPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(width: 12),
            _statCard(
              title: 'Biến động so với kỳ trước',
              value: changeText,
              icon: Icons.trending_up,
              color: change < 0
                  ? const Color(0xFFC62828)
                  : const Color(0xFF1565C0),
              caption: 'xu hướng',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              title: 'Tỷ lệ đất nông nghiệp',
              value: '${cropPercentage.toStringAsFixed(1)}%',
              icon: Icons.agriculture,
              color: const Color(0xFFF57C00),
              caption: 'hiện tại',
            ),
            const SizedBox(width: 12),
            _statCard(
              title: 'Độ che phủ mây',
              value: '${cloud.toStringAsFixed(1)}%',
              icon: Icons.cloud,
              color: const Color(0xFF5E35B1),
              caption: 'chất lượng ảnh',
            ),
          ],
        ),
        if (survey != null && survey.available) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.place, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Khu vực ưu tiên khảo sát',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Diện tích đất nông nghiệp lớn nhất: ${survey.areaKm2.toStringAsFixed(3)} km²',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chiếm ${survey.percentageOfAgriculture.toStringAsFixed(1)}% tổng diện tích đất nông nghiệp.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (survey.centerLat != null &&
                          survey.centerLng != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tâm khảo sát: ${survey.centerLat!.toStringAsFixed(5)}, ${survey.centerLng!.toStringAsFixed(5)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

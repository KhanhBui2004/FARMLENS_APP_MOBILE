import 'package:flutter/material.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';

class RecommendationPanel extends StatelessWidget {
  final ComparisonModel? result;

  const RecommendationPanel({super.key, required this.result});

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _levelLabel(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return 'High abnormality';
      case 'medium':
        return 'Medium abnormality';
      default:
        return 'Low abnormality';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    final farmland = result!.farmlandTracking;
    final abnormality = result!.abnormality;
    final recommendation = result!.recommendation;

    if (farmland == null && abnormality == null && recommendation == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Decision support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (farmland != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        'Current farmland',
                        '${farmland.currentAgricultureAreaKm2.toStringAsFixed(2)} km²',
                        const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _miniStat(
                        'Change',
                        '${farmland.agricultureRelativeChangePercentage >= 0 ? '+' : ''}${farmland.agricultureRelativeChangePercentage.toStringAsFixed(2)}%',
                        farmland.agricultureRelativeChangePercentage < 0
                            ? const Color(0xFFC62828)
                            : const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              if (abnormality != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _levelColor(abnormality.level).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_levelLabel(abnormality.level)} • ${abnormality.priorityCheck ? "Field check recommended" : "Monitor periodically"}',
                    style: TextStyle(
                      color: _levelColor(abnormality.level),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  abnormality.reason,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (recommendation != null) ...[
                const Text(
                  'Suggested action',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.summary,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                if (recommendation.actions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...recommendation.actions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
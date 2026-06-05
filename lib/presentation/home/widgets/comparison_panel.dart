import 'package:flutter/material.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';

class ComparisonPanel extends StatelessWidget {
  final ComparisonModel? result;
  final String? error;

  const ComparisonPanel({super.key, required this.result, required this.error});

  List<String> _classOrder() {
    return [
      'Agriculture',
      'Barren',
      'Forest',
      'Rangeland',
      'Unknown',
      'Urban',
      'Water',
    ];
  }

  Color _classColor(String key) {
    switch (key) {
      case 'Agriculture':
        return const Color.fromARGB(255, 255, 255, 0);
      case 'Barren':
        return const Color.fromARGB(255, 232, 184, 153);
      case 'Forest':
        return const Color.fromARGB(255, 0, 255, 0);
      case 'Rangeland':
        return const Color.fromARGB(255, 255, 0, 255);
      case 'Unknown':
        return const Color.fromARGB(255, 0, 0, 0);
      case 'Urban':
        return const Color.fromARGB(255, 0, 255, 255);
      case 'Water':
        return const Color.fromARGB(255, 0, 0, 255);
      default:
        return Colors.grey;
    }
  }

  double _getArea(ComparisonClasses classes, String key) {
    switch (key) {
      case 'Agriculture':
        return classes.agriculture?.areaKm2 ?? 0.0;
      case 'Barren':
        return classes.barren?.areaKm2 ?? 0.0;
      case 'Forest':
        return classes.forest?.areaKm2 ?? 0.0;
      case 'Rangeland':
        return classes.rangeland?.areaKm2 ?? 0.0;
      case 'Unknown':
        return classes.unknown?.areaKm2 ?? 0.0;
      case 'Urban':
        return classes.urban?.areaKm2 ?? 0.0;
      case 'Water':
        return classes.water?.areaKm2 ?? 0.0;
      default:
        return 0.0;
    }
  }

  Color _deltaColor(double delta) {
    if (delta > 0) {
      return const Color(0xFF2E7D32);
    }
    if (delta < 0) {
      return const Color(0xFFC62828);
    }
    return Colors.grey.shade700;
  }

  String _formatDisplayDate(String date) {
    if (date.length >= 10) {
      final parts = date.substring(0, 10).split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    }
    return date;
  }

  Widget _buildComparisonTable(
    ComparisonTimelineItem first,
    ComparisonTimelineItem second,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land cover comparison',
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
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Class',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatDisplayDate(first.date),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatDisplayDate(second.date),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Δ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._classOrder().map((key) {
                final value1 = _getArea(first.classes, key);
                final value2 = _getArea(second.classes, key);
                final delta = value2 - value1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _classColor(key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(key, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(value1.toStringAsFixed(2)),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(value2.toStringAsFixed(2)),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _deltaColor(delta),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Region area: ${(first.regionAreaM2 / 1000000).toStringAsFixed(2)} km²',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Unit: km²',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null && error == null) {
      return const SizedBox.shrink();
    }
    if (result == null) {
      return Text(
        error ?? 'No timeline data available.',
        style: const TextStyle(color: Colors.redAccent),
      );
    }

    final timeline = result!.timeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (timeline.length >= 2)
          _buildComparisonTable(timeline[0], timeline[1])
        else
          const Text(
            'Not enough timeline data to compare.',
            style: TextStyle(color: Colors.redAccent),
          ),
      ],
    );
  }
}

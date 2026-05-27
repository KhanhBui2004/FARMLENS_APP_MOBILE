import 'package:flutter/material.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';

class ComparisonPanel extends StatelessWidget {
  final ComparisonModel? result;
  final String? error;

  const ComparisonPanel({super.key, required this.result, required this.error});

  List<String> _classOrder() {
    return [
      'agriculture',
      'barren',
      'forest',
      'rangeland',
      'unknown',
      'urban',
      'water',
    ];
  }

  Color _classColor(String key) {
    switch (key) {
      case 'agriculture':
        return const Color.fromARGB(255, 255, 255, 0);
      case 'barren':
        return const Color.fromARGB(255, 232, 184, 153);
      case 'forest':
        return const Color.fromARGB(255, 0, 255, 0);
      case 'rangeland':
        return const Color.fromARGB(255, 255, 0, 255);
      case 'unknown':
        return const Color.fromARGB(255, 0, 0, 0);
      case 'urban':
        return const Color.fromARGB(255, 0, 255, 255);
      case 'water':
        return const Color.fromARGB(255, 0, 0, 255);
      default:
        return Colors.grey;
    }
  }

  double _getArea(ComparisonClasses classes, String key) {
    switch (key) {
      case 'agriculture':
        return classes.agriculture?.area_km2 ?? 0.0;
      case 'barren':
        return classes.barren?.area_km2 ?? 0.0;
      case 'forest':
        return classes.forest?.area_km2 ?? 0.0;
      case 'rangeland':
        return classes.rangeland?.area_km2 ?? 0.0;
      case 'unknown':
        return classes.unknown?.area_km2 ?? 0.0;
      case 'urban':
        return classes.urban?.area_km2 ?? 0.0;
      case 'water':
        return classes.water?.area_km2 ?? 0.0;
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
                    flex: 3,
                    child: Text(
                      'Class',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        first.date,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        second.date,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
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
                        flex: 3,
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
                              child: Text(
                                key,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('${value1.toStringAsFixed(2)}'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('${value2.toStringAsFixed(2)}'),
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
                child: Text(
                  'Unit: km2',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

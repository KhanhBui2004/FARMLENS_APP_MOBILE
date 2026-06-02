import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:flutter/material.dart';

class ComparisonDetailsSheet extends StatelessWidget {
  final ComparisonModel item;

  const ComparisonDetailsSheet({super.key, required this.item});

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
        child: SingleChildScrollView(
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
                'Change detection details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow('Analysis ID', item.id),
              _DetailRow(
                'Location',
                '${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
              ),
              _DetailRow(
                'Cloud cover',
                '${item.cloud_cover.toStringAsFixed(1)}%',
              ),
              _DetailRow(
                'Dates',
                item.dates.isEmpty ? '-' : item.dates.join(' -> '),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
              const SizedBox(height: 8),
              if (item.timeline.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No timeline data available.',
                    style: TextStyle(color: Color(0xFF4A6B57)),
                  ),
                )
              else
                ...item.timeline.map((entry) => _TimelineCard(entry: entry)),
            ],
          ),
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

class _TimelineCard extends StatelessWidget {
  final ComparisonTimelineItem entry;

  const _TimelineCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0EEE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.date.isEmpty ? 'Unknown date' : entry.date,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F3B2D),
            ),
          ),
          const SizedBox(height: 8),
          _ClassAreaRow('Agriculture', entry.classes.agriculture),
          _ClassAreaRow('Barren', entry.classes.barren),
          _ClassAreaRow('Forest', entry.classes.forest),
          _ClassAreaRow('Rangeland', entry.classes.rangeland),
          _ClassAreaRow('Urban', entry.classes.urban),
          _ClassAreaRow('Water', entry.classes.water),
          _ClassAreaRow('Unknown', entry.classes.unknown),
        ],
      ),
    );
  }
}

class _ClassAreaRow extends StatelessWidget {
  final String label;
  final ComparisonClassArea? value;

  const _ClassAreaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2F4F3D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${value!.area_km2.toStringAsFixed(3)} km2',
            style: const TextStyle(color: Color(0xFF2F4F3D)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StatsActions extends StatelessWidget {
  final VoidCallback onSelectFirstTime;
  final VoidCallback onSelectSecondTime;
  final VoidCallback onRunAnalysis;
  final VoidCallback onChangeDetection;

  const StatsActions({
    super.key,
    required this.onSelectFirstTime,
    required this.onSelectSecondTime,
    required this.onRunAnalysis,
    required this.onChangeDetection,
  });

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x11000000)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFEAF4EA),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Quick actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 160,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _featureCard(
              icon: Icons.date_range,
              title: 'Select First Time',
              description: 'Choose the time for analysis.',
              color: const Color(0xFF2E7D32),
              onTap: onSelectFirstTime,
            ),
            _featureCard(
              icon: Icons.date_range,
              title: 'Select Second Time',
              description: 'Choose the time for comparison.',
              color: const Color(0xFF1565C0),
              onTap: onSelectSecondTime,
            ),
            _featureCard(
              icon: Icons.analytics,
              title: 'Run Analysis',
              description: 'Run the analysis on the selected data.',
              color: const Color(0xFFF57C00),
              onTap: onRunAnalysis,
            ),
            _featureCard(
              icon: Icons.compare_arrows,
              title: 'Change Detection',
              description: 'Detect changes in the selected data.',
              color: const Color(0xFF6D4C41),
              onTap: onChangeDetection,
            ),
          ],
        ),
      ],
    );
  }
}

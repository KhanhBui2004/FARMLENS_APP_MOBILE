import 'package:flutter/material.dart';

class StatsActions extends StatelessWidget {
  final double area;
  final double changePercent;
  final double confidence;
  final double cloud;
  final VoidCallback onSelectRegion;
  final VoidCallback onSelectTime;
  final VoidCallback onRunAnalysis;

  const StatsActions({
    super.key,
    required this.area,
    required this.changePercent,
    required this.confidence,
    required this.cloud,
    required this.onSelectRegion,
    required this.onSelectTime,
    required this.onRunAnalysis,
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
              const Spacer(),
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.28,
          children: [
            _featureCard(
              icon: Icons.crop_free,
              title: 'Select area',
              description: 'Draw or pick the field to analyze on the map.',
              color: const Color(0xFF2E7D32),
              onTap: onSelectRegion,
            ),
            _featureCard(
              icon: Icons.date_range,
              title: 'Select time',
              description:
                  'Choose the month or period for comparison.',
              color: const Color(0xFF1565C0),
              onTap: onSelectTime,
            ),
            _featureCard(
              icon: Icons.auto_graph,
              title: 'Vegetation change',
              description: 'Inspect crop growth variation across time.',
              color: const Color(0xFFF57C00),
              onTap: onRunAnalysis,
            ),
            _featureCard(
              icon: Icons.file_download,
              title: 'Export results',
              description: 'Generate a report for assessment and sharing.',
              color: const Color(0xFF6D4C41),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Analysis summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              title: 'Crop area',
              value: '${area.toStringAsFixed(1)} ha',
              icon: Icons.square_foot,
              color: const Color(0xFF2E7D32),
              caption: 'current',
            ),
            const SizedBox(width: 12),
            _statCard(
              title: 'Change vs. last period',
              value: '+${changePercent.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: const Color(0xFF1565C0),
              caption: 'trend',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              title: 'Model confidence',
              value: '${confidence.toStringAsFixed(1)}%',
              icon: Icons.verified,
              color: const Color(0xFFF57C00),
              caption: 'U-Net',
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
        const SizedBox(height: 18),
        const Text(
          'Time-series comparison',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
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
              _timelineRow(
                label: 'Current period',
                value: '${area.toStringAsFixed(1)} ha',
                progress: 0.82,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 14),
              _timelineRow(
                label: 'Previous period',
                value: '${(area - 10).toStringAsFixed(1)} ha',
                progress: 0.64,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insights, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crop area is trending upward, while cloud coverage remains within an acceptable range for analysis.',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.35,
                        ),
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
}

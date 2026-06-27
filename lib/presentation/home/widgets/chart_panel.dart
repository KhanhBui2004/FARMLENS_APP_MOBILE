import 'dart:math';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:flutter/material.dart';

class ChartPanel extends StatelessWidget {
  final StatisticsModel? latestStats;

  const ChartPanel({super.key, required this.latestStats});

  // String _formatKm2(double value) {
  //   return '${value.toStringAsFixed(2)} km²';
  // }

  // String _formatPercent(double value) {
  //   return '${value.toStringAsFixed(1)}%';
  // }

  List<_LandCoverSlice> _buildLandCoverSlices(StatisticsModel stats) {
    final classes = stats.classes;
    return [
      _LandCoverSlice(
        label: 'Đất nông nghiệp',
        percentage: classes.agriculture?.percentage ?? 0.0,
        color: const Color(0xFFE0C35A), // vàng nông nghiệp
      ),
      _LandCoverSlice(
        label: 'Đất trống',
        percentage: classes.barren?.percentage ?? 0.0,
        color: const Color(0xFFC49A6C), // nâu đất khô
      ),
      _LandCoverSlice(
        label: 'Rừng',
        percentage: classes.forest?.percentage ?? 0.0,
        color: const Color(0xFF2E7D32), // xanh lá đậm
      ),
      _LandCoverSlice(
        label: 'Đồng cỏ',
        percentage: classes.rangeland?.percentage ?? 0.0,
        color: const Color(0xFF8BC34A), // xanh cỏ
      ),
      _LandCoverSlice(
        label: 'Không xác định',
        percentage: classes.unknown?.percentage ?? 0.0,
        color: const Color(0xFF757575), // xám trung tính
      ),
      _LandCoverSlice(
        label: 'Đô thị',
        percentage: classes.urban?.percentage ?? 0.0,
        color: const Color(0xFFE53935), // đỏ đô urban
      ),
      _LandCoverSlice(
        label: 'Nước',
        percentage: classes.water?.percentage ?? 0.0,
        color: const Color(0xFF1E88E5), // xanh nước
      ),
    ];
  }

  // List<Map<String, dynamic>> _getLandCoverItems(StatisticsModel stats) {
  //   final classes = stats.classes;
  //   return [
  //     {
  //       'name': 'Đất nông nghiệp',
  //       'area': classes.agriculture?.area_km2 ?? 0.0,
  //       'percentage': classes.agriculture?.percentage ?? 0.0,
  //     },
  //     {
  //       'name': 'Đất trống',
  //       'area': classes.barren?.area_km2 ?? 0.0,
  //       'percentage': classes.barren?.percentage ?? 0.0,
  //     },
  //     {
  //       'name': 'Rừng',
  //       'area': classes.forest?.area_km2 ?? 0.0,
  //       'percentage': classes.forest?.percentage ?? 0.0,
  //     },
  //     {
  //       'name': 'Đồng cỏ/cây bụi',
  //       'area': classes.rangeland?.area_km2 ?? 0.0,
  //       'percentage': classes.rangeland?.percentage ?? 0.0,
  //     },
  //     {
  //       'name': 'Đất đô thị',
  //       'area': classes.urban?.area_km2 ?? 0.0,
  //       'percentage': classes.urban?.percentage ?? 0.0,
  //     },
  //     {
  //       'name': 'Mặt nước',
  //       'area': classes.water?.area_km2 ?? 0.0,
  //       'percentage': classes.water?.percentage ?? 0.0,
  //     },
  //   ];
  // }

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

  Widget _buildLandCoverChart() {
    if (latestStats == null) {
      return const SizedBox.shrink();
    }
    final slices = _buildLandCoverSlices(latestStats!);
    final total = slices.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );
    if (total <= 0) {
      return const Text(
        'Chưa có thống kê lớp phủ đất.',
        style: TextStyle(color: Colors.redAccent),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bố lớp phủ đất',
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(painter: _PieChartPainter(slices: slices)),
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: slices
                        .where((slice) => slice.percentage > 0)
                        .map(
                          (slice) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _legendItem(
                              color: slice.color,
                              label:
                                  '${slice.label} (${slice.percentage.toStringAsFixed(1)}%)',
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  Text(
                    'Tổng diện tích: ${((latestStats!.regionAreaM2 / 1000000.0).toStringAsFixed(2))} km²',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLandCoverChart();
  }
}

class _LandCoverSlice {
  final String label;
  final double percentage;
  final Color color;

  const _LandCoverSlice({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class _PieChartPainter extends CustomPainter {
  final List<_LandCoverSlice> slices;

  const _PieChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );
    if (total <= 0) {
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -pi / 2;
    for (final slice in slices) {
      if (slice.percentage <= 0) {
        continue;
      }
      final sweepAngle = (slice.percentage / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = slice.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    if (oldDelegate.slices.length != slices.length) {
      return true;
    }
    for (var i = 0; i < slices.length; i++) {
      if (oldDelegate.slices[i].percentage != slices[i].percentage) {
        return true;
      }
    }
    return false;
  }
}

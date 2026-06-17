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
                'Chi tiết phát hiện biến động',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow('ID', item.id),
              _DetailRow(
                'Vị trí',
                '${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
              ),
              _DetailRow(
                'Độ che phủ mây',
                '${item.cloudCover.toStringAsFixed(1)}%',
              ),
              _DetailRow(
                'Ngày',
                item.dates.isEmpty ? '-' : item.dates.join(' -> '),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nhận định & khuyến nghị',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
              const SizedBox(height: 8),
              if (item.farmlandTracking != null) ...[
                _DetailRow(
                  'Đất nông nghiệp hiện tại',
                  '${item.farmlandTracking!.currentAgricultureAreaKm2.toStringAsFixed(2)} km²',
                ),
                _DetailRow(
                  'Biến động đất nông nghiệp',
                  '${item.farmlandTracking!.agricultureRelativeChangePercentage >= 0 ? '+' : ''}${item.farmlandTracking!.agricultureRelativeChangePercentage.toStringAsFixed(2)}%',
                ),
              ],
              if (item.abnormality != null) ...[
                _DetailRow('Trạng thái', item.abnormality!.label),
                _DetailRow('Đánh giá', item.abnormality!.reason),
              ],
              if (item.recommendation != null) ...[
                _DetailRow('Hành động đề xuất', item.recommendation!.summary),
                const SizedBox(height: 8),
                ...item.recommendation!.actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            action,
                            style: const TextStyle(color: Color(0xFF2F4F3D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (item.recommendation != null &&
                  item.recommendation!.secondaryInsights.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Nhận định bổ sung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F3B2D),
                  ),
                ),
                const SizedBox(height: 8),
                ...item.recommendation!.secondaryInsights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            insight,
                            style: const TextStyle(color: Color(0xFF2F4F3D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Dòng thời gian biến động',
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
                    'Không có dữ liệu dòng thời gian.',
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
            entry.date.isEmpty ? 'Ngày không xác định' : entry.date,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F3B2D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Diện tích khu vực: ${(entry.regionAreaM2 / 1000000).toStringAsFixed(2)} km²',
            style: const TextStyle(color: Color(0xFF4A6B57), fontSize: 12),
          ),
          Text(
            'Kích thước hình ảnh: ${entry.imageSize['width'] ?? 0} x ${entry.imageSize['height'] ?? 0}',
            style: const TextStyle(color: Color(0xFF4A6B57), fontSize: 12),
          ),
          const SizedBox(height: 8),
          _ClassAreaRow('Đất nông nghiệp', entry.classes.agriculture),
          _ClassAreaRow('Đất trống', entry.classes.barren),
          _ClassAreaRow('Rừng', entry.classes.forest),
          _ClassAreaRow('Đồng cỏ', entry.classes.rangeland),
          _ClassAreaRow('Đô thị', entry.classes.urban),
          _ClassAreaRow('Nước', entry.classes.water),
          _ClassAreaRow('Không xác định', entry.classes.unknown),
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
            '${value!.areaKm2.toStringAsFixed(3)} km²',
            style: const TextStyle(color: Color(0xFF2F4F3D)),
          ),
        ],
      ),
    );
  }
}

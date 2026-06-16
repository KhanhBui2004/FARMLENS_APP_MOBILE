import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:flutter/material.dart';
import 'history_card.dart';

class ChangeDetectionList extends StatelessWidget {
  final List<ComparisonModel> items;
  final VoidCallback onDeleteAll;
  final ValueChanged<ComparisonModel> onItemTap;
  final ValueChanged<ComparisonModel> onDeleteItem;

  const ChangeDetectionList({
    super.key,
    required this.items,
    required this.onDeleteAll,
    required this.onItemTap,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Không có dữ liệu phát hiện biến động nào.'),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF3F8E5A)),
                SizedBox(width: 8),
                Text(
                  'Lịch sử của bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B4A32),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onDeleteAll,
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final dateRange = item.dates.isNotEmpty
                ? '${item.dates.first} → ${item.dates.last}'
                : 'Không có ngày';

            final farmland = item.farmlandTracking;
            final abnormality = item.abnormality;

            final currentFarmland = farmland != null
                ? '${farmland.currentAgricultureAreaKm2.toStringAsFixed(2)} km²'
                : '-';

            final changeText = farmland != null
                ? '${farmland.agricultureRelativeChangePercentage >= 0 ? '+' : ''}${farmland.agricultureRelativeChangePercentage.toStringAsFixed(2)}%'
                : '-';

            final statusText = abnormality?.label ?? 'Stable';

            return HistoryCard(
              title: 'Phát hiện biến động ${index + 1}',
              subtitle: dateRange,
              lines: [
                'Đất nông nghiệp hiện tại: $currentFarmland',
                'Thay đổi: $changeText',
                'Trạng thái: $statusText',
                'Che phủ mây: ${item.cloudCover.toStringAsFixed(1)}%',
                'Vị trí: ${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}',
              ],
              onTap: () => onItemTap(item),
              onDelete: () => onDeleteItem(item),
            );
          },
        ),
      ],
    );
  }
}

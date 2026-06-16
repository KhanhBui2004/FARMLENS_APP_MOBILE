import 'package:farmlens_app/data/models/analysis/segmentation_model.dart';
import 'package:flutter/material.dart';
import 'history_card.dart';

class SegmentationList extends StatelessWidget {
  final List<SegmentationModel> items;
  final VoidCallback onDeleteAll;
  final ValueChanged<SegmentationModel> onItemTap;
  final ValueChanged<SegmentationModel> onDeleteItem;

  const SegmentationList({
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
          child: Text('Không có dữ liệu phân đoạn nào.'),
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
            return HistoryCard(
              title: 'Phân tích ${index + 1}',
              subtitle: 'Ngày: ${item.date}',
              lines: [
                'Che phủ mây: ${item.cloudCover.toStringAsFixed(1)}%',
                'Diện tích: ${(item.regionAreaM2 / 1000000).toStringAsFixed(2)} km²',
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

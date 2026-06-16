import 'package:flutter/material.dart';

class ExportSection extends StatelessWidget {
  final void Function(String) onExport;
  final bool canExport;
  final bool isExporting;

  const ExportSection({
    super.key,
    required this.onExport,
    this.canExport = true,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.ios_share, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'Xuất báo cáo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            canExport
                ? 'Xuất kết quả phân tích hiện tại dưới dạng báo cáo PDF để phục vụ theo dõi, đánh giá và trình bày.'
                : 'Vui lòng chạy phân tích phân đoạn trước khi xuất báo cáo.',
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canExport && !isExporting
                  ? () => onExport('PDF')
                  : null,
              icon: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(isExporting ? 'Đang xuất...' : 'Xuất báo cáo PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: null,
          //         icon: const Icon(Icons.table_view),
          //         label: const Text('Excel sắp có'),
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: null,
          //         icon: const Icon(Icons.image),
          //         label: const Text('Ảnh sắp có'),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
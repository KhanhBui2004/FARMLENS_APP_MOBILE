import 'package:flutter/material.dart';

class HistoryTabSelector extends StatelessWidget {
  final bool isSegmentationTab;
  final VoidCallback onSegmentationTap;
  final VoidCallback onChangeDetectionTap;

  const HistoryTabSelector({
    super.key,
    required this.isSegmentationTab,
    required this.onSegmentationTap,
    required this.onChangeDetectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Phân đoạn',
              isActive: isSegmentationTab,
              onTap: onSegmentationTap,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabButton(
              label: 'Phát hiện biến động',
              isActive: !isSegmentationTab,
              onTap: onChangeDetectionTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF3F8E5A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF2B4A32),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

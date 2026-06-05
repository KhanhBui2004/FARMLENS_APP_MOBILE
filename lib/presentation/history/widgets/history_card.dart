import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> lines;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lines,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F3B2D),
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF4A6B57),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ...lines.map(
                (text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    text,
                    style: const TextStyle(color: Color(0xFF2F4F3D)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

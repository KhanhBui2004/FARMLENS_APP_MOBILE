import 'package:farmlens_app/presentation/widgets/buttonCustom_widget.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  final List<Map<String, String>> _previewImages = const [
    {'title': 'Google Maps', 'asset': 'assets/images/image.png'},
    {'title': 'Ảnh vệ tinh', 'asset': 'assets/images/landcover.jpg'},
    {'title': 'Kết quả phân đoạn', 'asset': 'assets/images/segmentation.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6FBF5),
                  Color(0xFFEAF4EA),
                  Color(0xFFFDFEFE),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF3F8E5A).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.public,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Farmlens',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'PLATFORM PHÂN TÍCH ẢNH VỆ TINH',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Phân tích lớp phủ đất từ ảnh vệ tinh',
                    style: TextStyle(
                      color: Color(0xFF143D2A),
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Phát hiện nông nghiệp, rừng, đô thị, nước và các loại lớp phủ đất khác bằng cách sử dụng ảnh vệ tinh và phân đoạn AI.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.62),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Image carousel
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _previewImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = _previewImages[index];

                        return Container(
                          width: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(item['asset']!, fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.55),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                  child: Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Feature cards
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.map_outlined,
                          title: 'Ảnh vệ tinh',
                          subtitle: 'Phân loại lớp phủ đất',
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.analytics_outlined,
                          title: 'Thống kê',
                          subtitle: 'Xem thống kê khu vực',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  Row(
                    children: [
                      Expanded(
                        child: ButtonCustomWidget(
                          text: 'Đăng nhập',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.login),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.register),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(
                              color: colorScheme.primary.withValues(
                                alpha: 0.55,
                              ),
                              width: 1.3,
                            ),
                            shadowColor: Colors.black.withValues(alpha: 0.15),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),

                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 17),
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF143D2A),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

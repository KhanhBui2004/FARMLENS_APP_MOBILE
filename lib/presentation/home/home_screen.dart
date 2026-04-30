import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _timeValue = 0.62;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width > 900 ? 760.0 : double.infinity;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel(
                    title: 'Search location',
                    icon: Icons.place_outlined,
                    accent: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _SearchBar(
                    hintText: 'Enter farm, district, or coordinates',
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 18),
                  //  Map
                  AspectRatio(
                    aspectRatio: width > 900 ? 1.8 : 0.86,
                    child: _MapPanel(colorScheme: colorScheme),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _SectionLabel(
                        title: 'Time Slider',
                        icon: Icons.schedule_outlined,
                        accent: colorScheme.primary,
                      ),
                      const Spacer(),
                      _InfoPill(
                        icon: Icons.timeline_outlined,
                        label: 'Snapshot: ${(_timeValue * 100).round()}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _BottomControls(
                    colorScheme: colorScheme,
                    timeValue: _timeValue,
                    onTimeChanged: (value) {
                      setState(() {
                        _timeValue = value;
                      });
                    },
                    onAnalyze: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Analyzing map layers...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF5E7E66),
                      const Color(0xFF476655),
                      const Color(0xFF2B4036),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: CustomPaint(
                  painter: _FieldGridPainter(),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.2),
                    radius: 1.1,
                    colors: [
                      Colors.white.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _InfoPill(
                icon: Icons.satellite_alt_outlined,
                label: 'satellite',
                background: Colors.white.withOpacity(0.12),
                foreground: Colors.white,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _InfoPill(
                icon: Icons.hub_outlined,
                label: 'segmentation',
                background: Colors.white.withOpacity(0.12),
                foreground: Colors.white,
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 88,
              child: Column(
                children: [
                  Text(
                    'MAP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'satellite + segmentation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.86),
                        ),
                  ),
                ],
              ),
            ),
            const Center(
              child: _MapPin(),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _MapMeta(label: 'NDVI', value: '0.82'),
                  _MapMeta(label: 'Area', value: '1.24 ha'),
                  _MapMeta(label: 'Status', value: 'Healthy'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.colorScheme,
    required this.timeValue,
    required this.onTimeChanged,
    required this.onAnalyze,
  });

  final ColorScheme colorScheme;
  final double timeValue;
  final ValueChanged<double> onTimeChanged;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EBDD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: const Color(0xFFDDE6D9),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.12),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: timeValue,
              onChanged: onTimeChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time window',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF5E6B5E),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Early morning to late afternoon',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7A8578),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: onAnalyze,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analyze'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hintText, required this.colorScheme});

  final String hintText;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE6D9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hintText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF738173),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.tune_rounded, color: Color(0xFF748372)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.accent,
  });

  final String title;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF243126),
              ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final pillForeground = foreground ?? const Color(0xFF365043);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFEAF3E6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: pillForeground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: pillForeground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MapMeta extends StatelessWidget {
  const _MapMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.72),
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE3F3D8), Color(0xFF8CCF9A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.my_location_rounded, color: Color(0xFF264634), size: 30),
        ),
      ),
    );
  }
}

class _FieldGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const stepX = 52.0;
    const stepY = 58.0;

    for (double x = 0; x <= size.width; x += stepX) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += stepY) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final pathPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.56,
        size.height * 0.64,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.72,
        size.width * 0.94,
        size.height * 0.48,
      );

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

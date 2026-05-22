import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final void Function(String) onMenuSelected;
  final String title;
  final String subtitle;

  const HomeHeader({
    super.key,
    required this.onMenuSelected,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 42),
            onSelected: onMenuSelected,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Home',
                child: const Row(
                  children: [
                    Icon(Icons.home, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Home'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Change Detection',
                child: const Row(
                  children: [
                    Icon(Icons.change_history, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Change Detection'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'History',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('History'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(Icons.menu, color: Colors.green[700]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade900,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ButtonCustomWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  const ButtonCustomWidget({super.key, this.onPressed, required this.text});

  @override
  State<ButtonCustomWidget> createState() => _ButtonCustomWidgetState();
}

class _ButtonCustomWidgetState extends State<ButtonCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 92, 48),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

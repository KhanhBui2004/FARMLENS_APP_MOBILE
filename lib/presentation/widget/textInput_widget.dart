import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const TextInputWidget({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.keyboardType,
    this.controller,
  });

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late FocusNode _focusNode;
  bool isFocused = false;
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFFF1F1FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused
              ? const Color.fromARGB(255, 107, 161, 205)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

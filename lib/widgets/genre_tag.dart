import 'package:flutter/material.dart';

class GenreTag extends StatelessWidget {
  final String label;

  const GenreTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5C4FCF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProgressionRow extends StatelessWidget {
  final List<String> chords;
  final String highlightChord;
  final void Function(String chordName)? onChordTap;

  const ProgressionRow({
    super.key,
    required this.chords,
    required this.highlightChord,
    this.onChordTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chords.length; i++) ...[
            _ChordPill(
              label: chords[i],
              highlight: chords[i] == highlightChord,
              onTap: onChordTap != null ? () => onChordTap!(chords[i]) : null,
            ),
            if (i < chords.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('→', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
              ),
          ],
        ],
      ),
    );
  }
}

class _ChordPill extends StatelessWidget {
  final String label;
  final bool highlight;
  final VoidCallback? onTap;

  const _ChordPill({required this.label, required this.highlight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF5C4FCF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: highlight ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlight ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}

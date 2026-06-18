import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/services/audio_service.dart';
import 'package:chord_sense/widgets/genre_tag.dart';
import 'package:chord_sense/widgets/progression_row.dart';
import 'package:chord_sense/widgets/practice_prompt_card.dart';
import 'package:chord_sense/widgets/chord_bottom_sheet.dart';

class ChordDetailScreen extends StatefulWidget {
  final ChordMeta chord;

  const ChordDetailScreen({super.key, required this.chord});

  @override
  State<ChordDetailScreen> createState() => _ChordDetailScreenState();
}

class _ChordDetailScreenState extends State<ChordDetailScreen> {
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = StorageService.isSaved(widget.chord.name);
  }

  Future<void> _toggleSave() async {
    await StorageService.toggleSave(widget.chord.name);
    setState(() {
      _saved = StorageService.isSaved(widget.chord.name);
    });
  }

  void _showChordSheet(String chordName) {
    showChordBottomSheet(
      context: context,
      chordName: chordName,
      meta: findChordMeta(chordName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chord = widget.chord;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          GestureDetector(
            onTap: _toggleSave,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                _saved ? Icons.star_rounded : Icons.star_border_rounded,
                color: _saved ? const Color(0xFF5C4FCF) : const Color(0xFF888888),
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                chord.name,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                spacing: 8,
                children: chord.genres.map((g) => GenreTag(label: g)).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 220,
                height: 260,
                child: FlutterGuitarChord(
                  baseFret: chord.baseFret,
                  chordName: chord.name,
                  fingers: chord.fingers,
                  frets: chord.frets,
                  totalString: chord.stringCount,
                  stringStroke: 1.5,
                  firstFrameStroke: 8,
                  firstFrameColor: const Color(0xFF1A1A2E),
                  barColor: const Color(0xFF5C4FCF),
                  tabBackgroundColor: const Color(0xFF5C4FCF),
                  tabForegroundColor: Colors.white,
                  labelColor: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            Center(
              child: IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded, size: 48, color: Color(0xFF5C4FCF)),
                onPressed: () => AudioService.playChord(chord),
                tooltip: 'Play chord',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'WHERE YOU\'LL FIND THIS CHORD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _InfoCard(label: 'KEY', value: chord.inKey)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'ROLE',
                      value: chord.role,
                      subtitle: chord.roleDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PracticePromptCard(prompt: chord.practicePrompt),
            const SizedBox(height: 28),
            const Text(
              'COMMON PROGRESSIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            ...chord.progressions.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888888),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            p.genre,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ProgressionRow(
                        chords: p.chords,
                        highlightChord: chord.name,
                        onChordTap: (name) => _showChordSheet(name),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _InfoCard({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }
}

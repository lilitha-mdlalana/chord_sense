import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:intl/intl.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/services/audio_service.dart';
import 'package:chord_sense/widgets/genre_tag.dart';
import 'package:chord_sense/widgets/progression_row.dart';
import 'package:chord_sense/widgets/practice_prompt_card.dart';
import 'package:chord_sense/widgets/chord_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChordMeta _chord;
  bool _saved = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _chord = getDailyChord();
    _saved = StorageService.isSaved(_chord.name);
    _streak = StorageService.getStreak();
  }

  void _shuffle() {
    setState(() {
      _chord = shuffleChord(excludeName: _chord.name);
      _saved = StorageService.isSaved(_chord.name);
    });
  }

  void _showChordSheet(String chordName) {
    final meta = findChordMeta(chordName);
    showChordBottomSheet(context: context, chordName: chordName, meta: meta);
  }

  Future<void> _toggleSave() async {
    await StorageService.toggleSave(_chord.name);
    setState(() {
      _saved = StorageService.isSaved(_chord.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE · MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _Header(streak: _streak),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _chord.name,
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
                  children: _chord.genres.map((g) => GenreTag(label: g)).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 260,
                  child: FlutterGuitarChord(
                    baseFret: _chord.baseFret,
                    chordName: _chord.name,
                    fingers: _chord.fingers,
                    frets: _chord.frets,
                    totalString: _chord.stringCount,
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
                  onPressed: () => AudioService.playChord(_chord),
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
                    Expanded(child: _InfoCard(label: 'KEY', value: _chord.inKey)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: 'ROLE',
                        value: _chord.role,
                        subtitle: _chord.roleDesc,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PracticePromptCard(prompt: _chord.practicePrompt),
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
              ..._chord.progressions.map((p) => Padding(
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
                          highlightChord: _chord.name,
                          onChordTap: (name) => _showChordSheet(name),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _shuffle,
                      icon: const Icon(Icons.shuffle_rounded),
                      label: const Text(
                        'Shuffle',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C4FCF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _toggleSave,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _saved ? const Color(0xFF5C4FCF) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _saved ? Icons.star_rounded : Icons.star_border_rounded,
                        color: _saved ? Colors.white : const Color(0xFF888888),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int streak;
  const _Header({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'CHORD OF THE DAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C4FCF),
            letterSpacing: 1.2,
          ),
        ),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🔥 $streak day streak',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65100),
              ),
            ),
          ),
      ],
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

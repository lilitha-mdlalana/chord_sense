import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/progression_service.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/services/audio_service.dart';
import 'package:chord_sense/widgets/chord_bottom_sheet.dart';
import 'package:chord_sense/widgets/genre_tag.dart';

const _ink = Color(0xFF1A1A2E);
const _purple = Color(0xFF5C4FCF);
const _grey = Color(0xFF888888);

class ProgressionDetailScreen extends StatefulWidget {
  final ProgressionDef def;
  final String initialKey;

  const ProgressionDetailScreen({super.key, required this.def, this.initialKey = 'C'});

  @override
  State<ProgressionDetailScreen> createState() => _ProgressionDetailScreenState();
}

class _ProgressionDetailScreenState extends State<ProgressionDetailScreen> {
  late String _keyRoot;
  int _position = 0; // index into each chord's voicing list ("Position 1..5")
  bool _alternate = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _keyRoot = widget.initialKey;
  }

  List<String> get _chordNames {
    final tokens = _alternate
        ? alternateTokens(widget.def.roman, _position)
        : widget.def.roman;
    return tokens.map((t) => resolveRomanChord(t, _keyRoot)).toList();
  }

  ChordVoicing? _voicingFor(ChordMeta meta) {
    if (meta.voicings.isEmpty) {
      return ChordVoicing(frets: meta.frets, fingers: meta.fingers, baseFret: meta.baseFret);
    }
    return meta.voicings[_position.clamp(0, meta.voicings.length - 1)];
  }

  Future<void> _playAll() async {
    if (_playing) return;
    setState(() => _playing = true);
    for (final name in _chordNames) {
      final meta = findChordMeta(name);
      if (meta == null) continue;
      final v = _voicingFor(meta)!;
      await AudioService.playFrets(v.frets, v.baseFret);
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
    }
    if (mounted) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    final chordNames = _chordNames;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: StorageService.savedProgressions,
            builder: (context, _, _) {
              final saved = StorageService.isProgressionSaved(def.id, _keyRoot);
              return IconButton(
                onPressed: () => StorageService.toggleSaveProgression(def.id, _keyRoot),
                icon: Icon(
                  saved ? Icons.star_rounded : Icons.star_border_rounded,
                  color: saved ? _purple : _grey,
                  size: 28,
                ),
                tooltip: 'Save in this key',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              def.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: def.styles.map((s) => GenreTag(label: s)).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              def.description,
              style: const TextStyle(fontSize: 14, color: _grey, height: 1.4),
            ),
            const SizedBox(height: 20),
            _sectionLabel('KEY'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final k in kMajorKeys) ...[
                    _KeyChip(
                      label: def.minorKey ? '${k}m' : k,
                      selected: k == _keyRoot,
                      onTap: () => setState(() => _keyRoot = k),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _sectionLabel('POSITION')),
                _ShapesToggle(
                  alternate: _alternate,
                  onChanged: (v) => setState(() => _alternate = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  _KeyChip(
                    label: '${i + 1}',
                    selected: i == _position,
                    onTap: () => setState(() => _position = i),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  keyDisplayName(widget.def, _keyRoot).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _grey,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton.icon(
                  onPressed: _playing ? null : _playAll,
                  icon: Icon(
                    _playing ? Icons.graphic_eq_rounded : Icons.play_circle_fill_rounded,
                    color: _purple,
                  ),
                  label: Text(
                    _playing ? 'Playing…' : 'Play all',
                    style: const TextStyle(color: _purple, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                for (final name in chordNames) _ChordCard(
                  name: name,
                  meta: findChordMeta(name),
                  voicingFor: _voicingFor,
                  onTap: () => showChordBottomSheet(
                    context: context,
                    chordName: name,
                    meta: findChordMeta(name),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _grey,
          letterSpacing: 1.0,
        ),
      );
}

class _KeyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KeyChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _ink,
          ),
        ),
      ),
    );
  }
}

class _ShapesToggle extends StatelessWidget {
  final bool alternate;
  final ValueChanged<bool> onChanged;

  const _ShapesToggle({required this.alternate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg('Standard', !alternate, () => onChanged(false)),
          _seg('Alternate', alternate, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? _ink : _grey,
          ),
        ),
      ),
    );
  }
}

class _ChordCard extends StatelessWidget {
  final String name;
  final ChordMeta? meta;
  final ChordVoicing? Function(ChordMeta) voicingFor;
  final VoidCallback onTap;

  const _ChordCard({
    required this.name,
    required this.meta,
    required this.voicingFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = meta;
    final v = m != null ? voicingFor(m) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8E8E8)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: v != null
                  ? FlutterGuitarChord(
                      baseFret: v.baseFret,
                      chordName: name,
                      fingers: v.fingers,
                      frets: v.frets,
                      totalString: m!.stringCount,
                      stringStroke: 1.2,
                      firstFrameStroke: 6,
                      firstFrameColor: _ink,
                      barColor: _purple,
                      tabBackgroundColor: _purple,
                      tabForegroundColor: Colors.white,
                      labelColor: Colors.transparent,
                    )
                  : const Center(
                      child: Text(
                        'No diagram',
                        style: TextStyle(color: _grey, fontSize: 12),
                      ),
                    ),
            ),
            if (v != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.play_circle_fill_rounded, color: _purple, size: 28),
                onPressed: () => AudioService.playFrets(v.frets, v.baseFret),
              ),
          ],
        ),
      ),
    );
  }
}

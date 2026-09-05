import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/services/audio_service.dart';

const _ink = Color(0xFF1A1A2E);
const _purple = Color(0xFF5C4FCF);
const _grey = Color(0xFF888888);

void showChordBottomSheet({
  required BuildContext context,
  required String chordName,
  required ChordMeta? meta,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) {
        bool saved = StorageService.isSaved(chordName);

        Future<void> toggle() async {
          await StorageService.toggleSave(chordName);
          setSheetState(() {});
        }

        return _ChordSheetBody(
          chordName: chordName,
          meta: meta,
          saved: saved,
          onToggleSave: toggle,
        );
      },
    ),
  );
}

class _ChordSheetBody extends StatefulWidget {
  final String chordName;
  final ChordMeta? meta;
  final bool saved;
  final Future<void> Function() onToggleSave;

  const _ChordSheetBody({
    required this.chordName,
    required this.meta,
    required this.saved,
    required this.onToggleSave,
  });

  @override
  State<_ChordSheetBody> createState() => _ChordSheetBodyState();
}

class _ChordSheetBodyState extends State<_ChordSheetBody> {
  int _position = 0;

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    final voicings = meta == null
        ? const <ChordVoicing>[]
        : (meta.voicings.isEmpty
            ? [ChordVoicing(frets: meta.frets, fingers: meta.fingers, baseFret: meta.baseFret)]
            : meta.voicings);
    final voicing = voicings.isEmpty ? null : voicings[_position.clamp(0, voicings.length - 1)];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.chordName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await widget.onToggleSave();
                  setState(() {});
                },
                child: Icon(
                  widget.saved ? Icons.star_rounded : Icons.star_border_rounded,
                  color: widget.saved ? _purple : _grey,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (voicing != null) ...[
            SizedBox(
              width: 300,
              height: 230,
              child: FlutterGuitarChord(
                // Key forces a rebuild when the voicing changes.
                key: ValueKey('$_position-${voicing.frets}'),
                baseFret: voicing.baseFret,
                chordName: widget.chordName,
                fingers: voicing.fingers,
                frets: voicing.frets,
                totalString: widget.meta!.stringCount,
                stringStroke: 1.5,
                firstFrameStroke: 8,
                firstFrameColor: _ink,
                barColor: _purple,
                tabBackgroundColor: _purple,
                tabForegroundColor: Colors.white,
                labelColor: _ink,
              ),
            ),
            if (voicings.length > 1) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: _ink),
                    onPressed: _position > 0
                        ? () => setState(() => _position--)
                        : null,
                  ),
                  Text(
                    'Position ${_position + 1} of ${voicings.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _grey,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: _ink),
                    onPressed: _position < voicings.length - 1
                        ? () => setState(() => _position++)
                        : null,
                  ),
                ],
              ),
            ],
            IconButton(
              icon: const Icon(Icons.play_circle_fill_rounded, size: 48, color: _purple),
              onPressed: () => AudioService.playFrets(voicing.frets, voicing.baseFret),
              tooltip: 'Play chord',
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Chord diagram not available',
                style: TextStyle(color: _grey, fontSize: 15),
              ),
            ),
        ],
      ),
    );
  }
}

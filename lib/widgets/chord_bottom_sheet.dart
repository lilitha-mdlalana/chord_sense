import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/services/audio_service.dart';

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
                    chordName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: toggle,
                    child: Icon(
                      saved ? Icons.star_rounded : Icons.star_border_rounded,
                      color: saved ? const Color(0xFF5C4FCF) : const Color(0xFF888888),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (meta != null)
                SizedBox(
                  width: 300,
                  height: 240,
                  child: FlutterGuitarChord(
                    baseFret: meta.baseFret,
                    chordName: meta.name,
                    fingers: meta.fingers,
                    frets: meta.frets,
                    totalString: meta.stringCount,
                    stringStroke: 1.5,
                    firstFrameStroke: 8,
                    firstFrameColor: const Color(0xFF1A1A2E),
                    barColor: const Color(0xFF5C4FCF),
                    tabBackgroundColor: const Color(0xFF5C4FCF),
                    tabForegroundColor: Colors.white,
                    labelColor: const Color(0xFF1A1A2E),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Chord diagram not available',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 15),
                  ),
                ),
              if (meta != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 48, color: Color(0xFF5C4FCF)),
                  onPressed: () => AudioService.playChord(meta),
                  tooltip: 'Play chord',
                ),
            ],
          ),
        );
      },
    ),
  );
}

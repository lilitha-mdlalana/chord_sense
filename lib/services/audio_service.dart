import 'package:flutter/foundation.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:chord_sense/models/chord_data.dart';

class AudioService {
  static final _midi = MidiPro();
  static int? _sfId;
  static bool _loadFailed = false;

  static const _openStrings = [40, 45, 50, 55, 59, 64]; // low E → high E
  static const _channel = 0;
  static const _velocity = 100;
  static const _strumDelayMs = 22;
  static const _sustainMs = 2000;

  static Future<void> _ensureLoaded() async {
    if (_sfId != null || _loadFailed) return;
    try {
      _sfId = await _midi.loadSoundfontAsset(
        assetPath: 'assets/soundfonts/guitar.sf2',
        bank: 0,
        program: 25,
      );
      await _midi.selectInstrument(
        sfId: _sfId!,
        channel: _channel,
        bank: 0,
        program: 25,
      );
    } catch (e) {
      _loadFailed = true;
      debugPrint('AudioService: soundfont load failed — $e');
    }
  }

  static Future<void> playChord(ChordMeta chord) async {
    await _ensureLoaded();
    if (_sfId == null) return;

    final fretValues = chord.frets.split(' ').map(int.parse).toList();
    final notes = <int>[];

    for (int i = 0; i < fretValues.length && i < _openStrings.length; i++) {
      final f = fretValues[i];
      if (f == -1) continue;
      final midi = f == 0
          ? _openStrings[i]
          : _openStrings[i] + (chord.baseFret - 1) + f;
      notes.add(midi);
    }

    if (notes.isEmpty) return;

    for (int i = 0; i < notes.length; i++) {
      if (i > 0) await Future.delayed(const Duration(milliseconds: _strumDelayMs));
      _midi.playNote(sfId: _sfId!, channel: _channel, key: notes[i], velocity: _velocity);
    }

    Future.delayed(const Duration(milliseconds: _sustainMs), () {
      for (final note in notes) {
        _midi.stopNote(sfId: _sfId!, channel: _channel, key: note);
      }
    });
  }
}

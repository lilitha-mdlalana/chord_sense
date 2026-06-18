import 'dart:math';
import 'package:guitar_chord_library/guitar_chord_library.dart';
import 'package:chord_sense/models/chord_data.dart';

// --- Music theory helpers ---

const _noteToSemitone = {
  'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
  'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7,
  'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11,
};

const _semitoneToNote = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

const _numeralSemitone = {
  'I': 0, 'II': 2, 'III': 4, 'IV': 5, 'V': 7, 'VI': 9, 'VII': 11,
};

final _romanRe = RegExp(r'^([b#]?)(VII|VI|IV|V|III|II|I)(.*)$');


// --- Suffix metadata table ---

class _SuffixMeta {
  final List<String> genres;
  final String role;
  final String roleDesc;
  final String practicePrompt;
  final List<Progression> progressions;

  const _SuffixMeta({
    required this.genres,
    required this.role,
    required this.roleDesc,
    required this.practicePrompt,
    required this.progressions,
  });
}

const _suffixTable = <String, _SuffixMeta>{
  'major': _SuffixMeta(
  genres: ['POP', 'RNB'],
  role: 'I',
  roleDesc: 'Tonic',
  practicePrompt: 'Loop this progression and experiment with different strumming patterns. Try improvising a melody on top.',
  progressions: [
    Progression(
      label: 'POP CLASSIC',
      genre: 'POP',
      chords: ['I', 'V', 'VIm', 'IV'],
    ),
    Progression(
      label: 'SINGER SONGWRITER',
      genre: 'POP',
      chords: ['I', 'IV', 'V', 'IV'],
    ),
    Progression(
      label: 'RNB FEEL',
      genre: 'RNB',
      chords: ['I', 'IIIm', 'VIm', 'IV'],
    ),
    Progression(
      label: 'WORSHIP LOOP',
      genre: 'POP',
      chords: ['I', 'V', 'IV', 'V'],
    ),
    Progression(
      label: 'HEARTBEAT',
      genre: 'POP',
      chords: ['VIm', 'IV', 'I', 'V'],
    ),
  ],
),
  'minor': _SuffixMeta(
  genres: ['RNB', 'POP'],
  role: 'Im',
  roleDesc: 'Tonic Minor',
  practicePrompt: 'Listen to the emotional color of this minor key. Try improvising a melody over the loop.',
  progressions: [
    Progression(
      label: 'SAD POP',
      genre: 'POP',
      chords: ['Im', 'bVI', 'bIII', 'bVII'],
    ),
    Progression(
      label: 'MINOR RNB',
      genre: 'RNB',
      chords: ['Im', 'IVm', 'bVII', 'bIII'],
    ),
    Progression(
      label: 'ANDALUSIAN',
      genre: 'POP',
      chords: ['Im', 'bVII', 'bVI', 'V7'],
    ),
    Progression(
      label: 'DARK LOOP',
      genre: 'POP',
      chords: ['Im', 'bVII', 'bVI', 'bVII'],
    ),
    Progression(
      label: 'SOUL MINOR',
      genre: 'RNB',
      chords: ['Im', 'bIII', 'bVII', 'bVI'],
    ),
  ],
),
  'maj7': _SuffixMeta(
  genres: ['RNB', 'SOUL', 'JAZZ'],
  role: 'Imaj7',
  roleDesc: 'Major Seven',
  practicePrompt: 'Focus on the emotional color of the major seventh. Try picking through each chord slowly.',
  progressions: [
    Progression(
      label: 'NEO SOUL',
      genre: 'RNB',
      chords: ['Imaj7', 'IIIm7', 'VIm7', 'IVmaj7'],
    ),
    Progression(
      label: 'SMOOTH LOOP',
      genre: 'SOUL',
      chords: ['Imaj7', 'VIm7', 'IIm7', 'V7'],
    ),
    Progression(
      label: 'JAZZY POP',
      genre: 'POP',
      chords: ['IVmaj7', 'V7', 'IIIm7', 'VIm7'],
    ),
    Progression(
      label: 'GOSPEL SOUL',
      genre: 'SOUL',
      chords: ['Imaj7', 'VIm7', 'IVmaj7', 'V7'],
    ),
    Progression(
      label: 'DRIFTING',
      genre: 'RNB',
      chords: ['IIm7', 'V7', 'Imaj7', 'VI7'],
    ),
  ],
),
  'm7': _SuffixMeta(
  genres: ['RNB', 'SOUL', 'JAZZ'],
  role: 'IIm7',
  roleDesc: 'Minor Seven',
  practicePrompt: 'Try picking through each chord and listen for the smooth voice leading between them.',
  progressions: [
    Progression(
      label: 'II V I',
      genre: 'JAZZ',
      chords: ['IIm7', 'V7', 'Imaj7'],
    ),
    Progression(
      label: 'RNB LOOP',
      genre: 'RNB',
      chords: ['VIm7', 'IIm7', 'V7', 'Imaj7'],
    ),
    Progression(
      label: 'GOSPEL MOVE',
      genre: 'SOUL',
      chords: ['IVmaj7', 'IIIm7', 'IIm7', 'V7'],
    ),
    Progression(
      label: 'DORIAN VAMP',
      genre: 'RNB',
      chords: ['Im7', 'IV7', 'Im7', 'bVII7'],
    ),
    Progression(
      label: 'NEO SOUL LOOP',
      genre: 'RNB',
      chords: ['VIm7', 'IVmaj7', 'Imaj7', 'V7'],
    ),
  ],
),
  '7': _SuffixMeta(
    genres: ['BLUES', 'SOUL', 'JAZZ', 'RNB'],
    role: 'V7',
    roleDesc: 'Dominant',
    practicePrompt: 'Listen to how the tension resolves back home. Feel the pull of the dominant seventh.',
    progressions: [
      Progression(label: 'BLUES SHUFFLE', genre: 'BLUES', chords: ['I7', 'IV7', 'I7', 'V7']),
      Progression(label: 'JAZZ TURNAROUND', genre: 'JAZZ', chords: ['Imaj7', 'VI7', 'IIm7', 'V7']),
      Progression(label: 'R&B GROOVE', genre: 'SOUL', chords: ['I7', 'IVm7', 'I7', 'V7']),
      Progression(label: 'GOSPEL CHANGE', genre: 'SOUL', chords: ['I7', 'IV7', 'IVm7', 'I7']),
      Progression(label: 'SOUL RESOLVE', genre: 'SOUL', chords: ['IV7', 'IVm7', 'Imaj7', 'V7']),
    ],
  ),
  'dim': _SuffixMeta(
    genres: ['JAZZ', 'SOUL'],
    role: 'vii°',
    roleDesc: 'Leading Tone',
    practicePrompt: 'Play the diminished chord as a passing chord into the next. Notice how it creates forward movement.',
    progressions: [
      Progression(label: 'JAZZ APPROACH', genre: 'JAZZ', chords: ['#IVdim7', 'V7', 'Imaj7']),
      Progression(label: 'PASSING CHORD', genre: 'JAZZ', chords: ['Imaj7', '#Idim7', 'IIm7', 'V7']),
      Progression(label: 'GOSPEL LIFT', genre: 'SOUL', chords: ['IV', '#IVdim7', 'I', 'V']),
      Progression(label: 'GOSPEL STEP', genre: 'SOUL', chords: ['I', 'VIIdim7', 'I', 'V']),
      Progression(label: 'MINOR APPROACH', genre: 'JAZZ', chords: ['Im', 'IIdim7', 'Im', 'V7']),
    ],
  ),
  'm7b5': _SuffixMeta(
    genres: ['JAZZ'],
    role: 'IIø',
    roleDesc: 'Half Diminished',
    practicePrompt: 'Loop this minor ii-V-i and listen to how the tension builds and resolves to the home chord.',
    progressions: [
      Progression(label: 'MINOR II-V-I', genre: 'JAZZ', chords: ['IIm7b5', 'V7b9', 'Im']),
      Progression(label: 'MINOR CADENCE', genre: 'JAZZ', chords: ['IIm7b5', 'V7b9', 'Im7', 'IVm7']),
      Progression(label: 'NEO SOUL MINOR', genre: 'RNB', chords: ['Im7', 'IVm7', 'IIm7b5', 'V7']),
      Progression(label: 'JAZZ MINOR VAMP', genre: 'JAZZ', chords: ['Im', 'IVm7', 'IIm7b5', 'V7b9']),
      Progression(label: 'EXTENDED RESOLVE', genre: 'JAZZ', chords: ['IIm7b5', 'V7b9', 'Im', 'bVII7']),
    ],
  ),
};

final _defaultMeta = _SuffixMeta(
  genres: ['POP'],
  role: 'I',
  roleDesc: 'Tonic',
  practicePrompt: 'Play this progression repeatedly and improvise a melody over it.',
  progressions: [
    Progression(label: 'SIMPLE LOOP', genre: 'POP', chords: ['I', 'IV', 'V', 'I']),
    Progression(label: 'FOUR CHORD', genre: 'POP', chords: ['I', 'V', 'VIm', 'IV']),
    Progression(label: 'TURNAROUND', genre: 'POP', chords: ['I', 'VI', 'IV', 'V']),
    Progression(label: 'MINOR TOUCH', genre: 'POP', chords: ['I', 'VIm', 'IV', 'V']),
    Progression(label: 'BRIGHT LOOP', genre: 'POP', chords: ['I', 'IV', 'VIm', 'V']),
  ],
);

// --- Chord building ---

String _parentKey(String key, String suffix) {
  final isMinor = suffix.startsWith('m') && !suffix.startsWith('maj');
  return '$key ${isMinor ? 'Minor' : 'Major'}';
}

String _resolveChord(String roman, String rootKey, String chordName) {
  final m = _romanRe.firstMatch(roman);
  if (m == null) return roman;
  final accidental = m.group(1)!;
  final numeral = m.group(2)!;
  int semitones = _numeralSemitone[numeral]!;
  if (accidental == 'b') semitones -= 1;
  if (accidental == '#') semitones += 1;
  if (semitones == 0) return chordName;
  final rootSemitone = _noteToSemitone[rootKey] ?? 0;
  final note = _semitoneToNote[(rootSemitone + semitones) % 12];
  return '$note${m.group(3)!}';
}

List<Progression> _resolveProgressions(List<Progression> raw, String rootKey, String chordName) {
  return raw.map((p) {
    final resolved = p.chords.map((c) => _resolveChord(c, rootKey, chordName)).toList();
    return Progression(label: p.label, genre: p.genre, chords: resolved);
  }).toList();
}

String _resolvePracticePrompt(String prompt, String chordName) {
  return prompt.replaceAll('this chord', chordName);
}

List<ChordMeta> _allChords() {
  final instrument = GuitarChordLibrary.instrument();
  final keys = instrument.getKeys(true);
  final result = <ChordMeta>[];
  for (final key in keys) {
    final chords = instrument.getChordsByKey(key, true) ?? [];
    for (final chord in chords) {
      if (chord.chordPositions.isEmpty) continue;
      final pos = chord.chordPositions[0];
      final meta = _suffixTable[chord.suffix] ?? _defaultMeta;
      result.add(ChordMeta(
        name: chord.name,
        key: chord.chordKey,
        suffix: chord.suffix,
        frets: pos.frets,
        fingers: pos.fingers,
        baseFret: pos.baseFret,
        stringCount: instrument.stringCount,
        genres: meta.genres,
        inKey: _parentKey(chord.chordKey, chord.suffix),
        role: meta.role,
        roleDesc: meta.roleDesc,
        progressions: _resolveProgressions(meta.progressions, chord.chordKey, chord.name),
        practicePrompt: _resolvePracticePrompt(meta.practicePrompt, chord.name),
      ));
    }
  }
  return result;
}

List<ChordMeta>? _cachedAll;

List<ChordMeta> getAllChords() {
  _cachedAll ??= _allChords();
  return _cachedAll!;
}

void invalidateChordCache() {
  _cachedAll = null;
}

ChordMeta getDailyChord() {
  final all = getAllChords();
  final now = DateTime.now();
  final index = (now.year * 365 + now.month * 31 + now.day) % all.length;
  return all[index];
}

// Handles display names ('Am', 'C') → library names ('Aminor', 'Cmajor')
ChordMeta? findChordMeta(String displayName) {
  final all = getAllChords();
  final lower = displayName.toLowerCase();

  var found = all.where((c) => c.name.toLowerCase() == lower).firstOrNull;
  if (found != null) return found;

  // Pure note = major (e.g. 'C' → 'Cmajor')
  if (RegExp(r'^[a-g][b#]?$').hasMatch(lower)) {
    return all.where((c) => c.name.toLowerCase() == '${lower}major').firstOrNull;
  }

  // Note + 'm' only = minor (e.g. 'Am' → 'Aminor', but not 'Am7')
  if (RegExp(r'^[a-g][b#]?m$').hasMatch(lower)) {
    final note = lower.substring(0, lower.length - 1);
    return all.where((c) => c.name.toLowerCase() == '${note}minor').firstOrNull;
  }

  return null;
}

ChordMeta shuffleChord({String? excludeName}) {
  final all = getAllChords();
  final pool = excludeName != null ? all.where((c) => c.name != excludeName).toList() : all;
  return pool[Random().nextInt(pool.length)];
}

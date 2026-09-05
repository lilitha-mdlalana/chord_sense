import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';

// Progression catalog seeded from the songbooks:
// - 'Classics Vol. 1-3' → the nine pop/rock progressions themed around the 1
//   chord, each playable in all 12 keys with alternate shapes.
// - 'Style Encyclopedia' → style-based progressions (rock, folk, country,
//   latin, jazz, blues, swing, alternative) incl. minor-key patterns.

const kMajorKeys = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

const progressionCatalog = <ProgressionDef>[
  // --- Classics Vol. 1 ---
  ProgressionDef(
    id: 'c1_1',
    name: 'I – vi – IV – V',
    roman: ['I', 'VIm', 'IV', 'V'],
    source: 'Classics Vol. 1',
    styles: ['POP', 'ROCK'],
    description: 'The doo-wop classic — endless 50s and modern pop songs.',
  ),
  ProgressionDef(
    id: 'c1_2',
    name: 'I – V – vi – IV',
    roman: ['I', 'V', 'VIm', 'IV'],
    source: 'Classics Vol. 1',
    styles: ['POP'],
    description: 'The four-chord pop loop heard in countless hit songs.',
  ),
  ProgressionDef(
    id: 'c1_3',
    name: 'I – IV – V',
    roman: ['I', 'IV', 'V'],
    source: 'Classics Vol. 1',
    styles: ['ROCK', 'FOLK', 'COUNTRY'],
    description: 'The three-chord workhorse of rock, folk and country.',
  ),

  // --- Classics Vol. 2 ---
  ProgressionDef(
    id: 'c2_1',
    name: 'I – vi – ii – V',
    roman: ['I', 'VIm', 'IIm', 'V'],
    source: 'Classics Vol. 2',
    styles: ['POP', 'JAZZ', 'LATIN'],
    description: 'The classic turnaround — smooth circle-of-fifths motion home.',
  ),
  ProgressionDef(
    id: 'c2_2',
    name: 'I – IV – vi – V',
    roman: ['I', 'IV', 'VIm', 'V'],
    source: 'Classics Vol. 2',
    styles: ['POP', 'ROCK'],
    description: 'Bright start, minor dip, strong resolve — modern pop staple.',
  ),
  ProgressionDef(
    id: 'c2_3',
    name: 'I – IV – I – V',
    roman: ['I', 'IV', 'I', 'V'],
    source: 'Classics Vol. 2',
    styles: ['POP', 'FOLK'],
    description: 'Rocking between home and the 4 chord before lifting to the 5.',
  ),

  // --- Classics Vol. 3 ---
  ProgressionDef(
    id: 'c3_1',
    name: 'I – V – vi – iii',
    roman: ['I', 'V', 'VIm', 'IIIm'],
    source: 'Classics Vol. 3',
    styles: ['POP'],
    description: 'Descending pop ballad motion — first half of the Pachelbel walk.',
  ),
  ProgressionDef(
    id: 'c3_2',
    name: 'I – IV – ii – V',
    roman: ['I', 'IV', 'IIm', 'V'],
    source: 'Classics Vol. 3',
    styles: ['POP', 'JAZZ'],
    description: 'Swaps the vi for a IV — softer route into the ii–V cadence.',
  ),
  ProgressionDef(
    id: 'c3_3',
    name: 'I – iii – IV – V',
    roman: ['I', 'IIIm', 'IV', 'V'],
    source: 'Classics Vol. 3',
    styles: ['POP', 'SOUL'],
    description: 'Rising stepwise build from home all the way to the 5 chord.',
  ),

  // --- Style Encyclopedia: major keys ---
  ProgressionDef(
    id: 'se_color',
    name: 'Imaj7 – vi7 – ii7 – V7',
    roman: ['Imaj7', 'VIm7', 'IIm7', 'V7'],
    source: 'Style Encyclopedia',
    styles: ['JAZZ', 'POP'],
    description: 'The turnaround in color chords — 7ths on every degree.',
  ),
  ProgressionDef(
    id: 'se_blues7',
    name: 'I7 – IV7 – V7',
    roman: ['I7', 'IV7', 'I7', 'V7'],
    source: 'Style Encyclopedia',
    styles: ['BLUES', 'ROCK'],
    description: 'The three-chord blues — dominant 7ths all the way through.',
  ),
  ProgressionDef(
    id: 'se_12bar',
    name: '12-Bar Blues',
    roman: ['I7', 'IV7', 'I7', 'I7', 'IV7', 'IV7', 'I7', 'I7', 'V7', 'IV7', 'I7', 'V7'],
    source: 'Style Encyclopedia',
    styles: ['BLUES'],
    description: 'The full 12-bar form — one chord per bar, quick change in bar 2.',
  ),
  ProgressionDef(
    id: 'se_swing',
    name: 'Swing (dim7 passing)',
    roman: ['I', '#Idim7', 'IIm7', '#IIdim7', 'I', 'V7', 'IV', 'IIm7'],
    source: 'Style Encyclopedia',
    styles: ['SWING', 'JAZZ'],
    description: 'Diminished 7th passing chords walk the bass up between degrees.',
  ),
  ProgressionDef(
    id: 'se_jazzblues',
    name: 'I – VI7 – ii7 – V7',
    roman: ['I', 'VI7', 'IIm7', 'V7'],
    source: 'Style Encyclopedia',
    styles: ['JAZZ', 'BLUES'],
    description: 'Jazz-blues turnaround — the VI becomes a secondary dominant.',
  ),
  ProgressionDef(
    id: 'se_sus4',
    name: 'Isus4 – I – IVsus4 – IV',
    roman: ['Isus4', 'I', 'IVsus4', 'IV', 'Vsus4', 'V'],
    source: 'Style Encyclopedia',
    styles: ['ALT ROCK', 'ACOUSTIC'],
    description: 'Acoustic alt-rock suspension moves — each sus4 melts into its chord.',
  ),

  // --- Style Encyclopedia: minor keys ---
  ProgressionDef(
    id: 'se_min_145',
    name: 'i – iv – v',
    roman: ['Im', 'IVm', 'Vm'],
    source: 'Style Encyclopedia',
    styles: ['FOLK', 'ROCK', 'LATIN'],
    description: 'The minor-key three-chord pattern — dark cousin of I–IV–V.',
    minorKey: true,
  ),
  ProgressionDef(
    id: 'se_min_1563',
    name: 'i – V – VI – III',
    roman: ['Im', 'V7', 'bVI', 'bIII'],
    source: 'Style Encyclopedia',
    styles: ['LATIN', 'FOLK'],
    description: 'Minor-key journey out to the relative major and back.',
    minorKey: true,
  ),
  ProgressionDef(
    id: 'se_min_1346',
    name: 'i – III – IV – VI',
    roman: ['Im', 'bIII', 'IV', 'bVI'],
    source: 'Style Encyclopedia',
    styles: ['BLUES', 'ROCK', 'FOLK'],
    description: 'Substitutes a major IV for the usual minor iv — dorian brightness.',
    minorKey: true,
  ),
  ProgressionDef(
    id: 'se_min_7ths',
    name: 'i7 – iv7 – v7',
    roman: ['Im7', 'IVm7', 'Vm7'],
    source: 'Style Encyclopedia',
    styles: ['JAZZ', 'LATIN'],
    description: 'The minor three-chord pattern in smooth minor 7th voicings.',
    minorKey: true,
  ),
];

ProgressionDef? findProgressionDef(String id) =>
    progressionCatalog.where((p) => p.id == id).firstOrNull;

/// Resolve a progression into concrete chord names in the given key root.
List<String> resolveProgression(ProgressionDef def, String keyRoot) =>
    def.roman.map((t) => resolveRomanChord(t, keyRoot)).toList();

String keyDisplayName(ProgressionDef def, String keyRoot) =>
    '$keyRoot ${def.minorKey ? 'Minor' : 'Major'}';

// --- Alternate shapes (Classics-style color substitutions) ---
//
// The books swap plain triads for sus2/sus4/add9/M9 colors and give minor
// chords 7th/9th/11th extensions. Substitution depends on the chord quality
// and cycles with the position index so each position gets its own flavor.

const _majorAlts = ['sus2', 'sus4', 'add9', 'maj9'];
const _minorAlts = ['m7', 'm9', 'm11'];
const _domAlts = ['7sus4', '9'];

final _tokenQualityRe = RegExp(r'^([b#]?)(VII|VI|IV|V|III|II|I)(.*)$');

/// Alternate-shape version of the roman tokens for a given variation index.
/// Keeps the tonic anchored (books mostly leave the 1 chord plain) and
/// colors the rest.
List<String> alternateTokens(List<String> roman, int variation) {
  return [
    for (var i = 0; i < roman.length; i++)
      _alternateToken(roman[i], variation + i, keepPlain: i == 0),
  ];
}

String _alternateToken(String token, int seed, {bool keepPlain = false}) {
  if (keepPlain) return token;
  final m = _tokenQualityRe.firstMatch(token);
  if (m == null) return token;
  final base = '${m.group(1)}${m.group(2)}';
  final quality = m.group(3)!;

  if (quality == '' || quality == 'sus4' || quality == 'sus2') {
    return '$base${_majorAlts[seed % _majorAlts.length]}';
  }
  if (quality == 'm') {
    return '$base${_minorAlts[seed % _minorAlts.length]}';
  }
  if (quality == '7') {
    return '$base${_domAlts[seed % _domAlts.length]}';
  }
  // Already a color chord (maj7, m7, dim7…) — leave it.
  return token;
}

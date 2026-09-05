class Progression {
  final String label;
  final String genre;
  final List<String> chords;

  const Progression({
    required this.label,
    required this.genre,
    required this.chords,
  });
}

// One playable shape for a chord — mirrors the book's "Position 1..5".
class ChordVoicing {
  final String frets;
  final String fingers;
  final int baseFret;

  const ChordVoicing({
    required this.frets,
    required this.fingers,
    required this.baseFret,
  });
}

class ChordMeta {
  final String name;
  final String key;
  final String suffix;
  final String frets;
  final String fingers;
  final int baseFret;
  final int stringCount;
  final List<String> genres;
  final String inKey;
  final String role;
  final String roleDesc;
  final List<Progression> progressions;
  final String practicePrompt;
  final List<ChordVoicing> voicings;

  const ChordMeta({
    required this.name,
    required this.key,
    required this.suffix,
    required this.frets,
    required this.fingers,
    required this.baseFret,
    required this.stringCount,
    required this.genres,
    required this.inKey,
    required this.role,
    required this.roleDesc,
    required this.progressions,
    required this.practicePrompt,
    this.voicings = const [],
  });
}

// A named progression from the songbooks, defined in roman numerals and
// resolvable into any of the 12 keys.
class ProgressionDef {
  final String id;
  final String name; // e.g. 'I – vi – IV – V'
  final List<String> roman; // tokens the resolver understands, e.g. 'VIm', 'V7'
  final String source; // catalog section, e.g. 'Classics Vol. 1'
  final List<String> styles;
  final String description;
  final bool minorKey;

  const ProgressionDef({
    required this.id,
    required this.name,
    required this.roman,
    required this.source,
    required this.styles,
    required this.description,
    this.minorKey = false,
  });
}

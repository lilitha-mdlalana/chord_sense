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
  });
}

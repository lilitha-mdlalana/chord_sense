import 'package:flutter_test/flutter_test.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/progression_service.dart';

void main() {
  test('every progression resolves to known chords in all 12 keys', () {
    final missing = <String>{};
    for (final def in progressionCatalog) {
      for (final key in kMajorKeys) {
        for (final name in resolveProgression(def, key)) {
          if (findChordMeta(name) == null) missing.add('${def.id}/$key: $name');
        }
      }
    }
    expect(missing, isEmpty, reason: 'Unresolvable chords: $missing');
  });

  test('alternate shapes resolve to known chords in all 12 keys', () {
    final missing = <String>{};
    for (final def in progressionCatalog) {
      for (var pos = 0; pos < 5; pos++) {
        final tokens = alternateTokens(def.roman, pos);
        for (final key in kMajorKeys) {
          for (final t in tokens) {
            final name = resolveRomanChord(t, key);
            if (findChordMeta(name) == null) missing.add('${def.id}/$key/p$pos: $name');
          }
        }
      }
    }
    expect(missing, isEmpty, reason: 'Unresolvable alternate chords: $missing');
  });

  test('chords expose multiple voicings for the position selector', () {
    final c = findChordMeta('C');
    expect(c, isNotNull);
    expect(c!.voicings.length, greaterThan(1));
  });
}

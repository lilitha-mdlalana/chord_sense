import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSaved = 'saved_chords';
const _kStreak = 'streak_count';
const _kLastOpen = 'last_open_date';

class StorageService {
  static SharedPreferences? _prefs;

  // Single source of truth — every screen that listens to this
  // rebuilds the instant a chord is saved/unsaved, anywhere in the app.
  static final ValueNotifier<Set<String>> savedChords =
      ValueNotifier<Set<String>>({});

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    savedChords.value = _p.getStringList(_kSaved)?.toSet() ?? {};
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'StorageService.init() must be called first');
    return _prefs!;
  }

  static Set<String> getSaved() => savedChords.value;

  static Future<void> toggleSave(String chordName) async {
    final saved = Set<String>.from(savedChords.value);
    if (saved.contains(chordName)) {
      saved.remove(chordName);
    } else {
      saved.add(chordName);
    }
    await _p.setStringList(_kSaved, saved.toList());
    savedChords.value = saved;
  }

  static bool isSaved(String chordName) => savedChords.value.contains(chordName);

  // streak methods stay exactly as you had them
  static int getStreak() => _p.getInt(_kStreak) ?? 0;

  static Future<int> recordOpen() async {
    final today = _todayStr();
    final last = _p.getString(_kLastOpen);
    if (last == today) return getStreak();
    final streak = last == _yesterdayStr() ? getStreak() + 1 : 1;
    await _p.setInt(_kStreak, streak);
    await _p.setString(_kLastOpen, today);
    return streak;
  }

  static String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  static String _yesterdayStr() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${d.month}-${d.day}';
  }
}
import 'package:flutter/material.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/progression_service.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/screens/chord_detail_screen.dart';
import 'package:chord_sense/screens/progression_detail_screen.dart';

const _ink = Color(0xFF1A1A2E);
const _purple = Color(0xFF5C4FCF);
const _grey = Color(0xFF888888);

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _openDetail(BuildContext context, ChordMeta chord) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChordDetailScreen(chord: chord)));
    // no .then(_load) needed anymore — the notifier keeps everything in sync
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Saved',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink),
                ),
              ),
              const TabBar(
                labelColor: _purple,
                unselectedLabelColor: _grey,
                indicatorColor: _purple,
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Chords'),
                  Tab(text: 'Progressions'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _savedChordsList(),
                    _savedProgressionsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _savedChordsList() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: StorageService.savedChords,
      builder: (context, names, _) {
        final saved = getAllChords().where((c) => names.contains(c.name)).toList();
        if (saved.isEmpty) {
          return _emptyState('Save chords to revisit them later');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: saved.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
          itemBuilder: (context, i) {
            final chord = saved[i];
            return Dismissible(
              key: Key(chord.name),
              direction: DismissDirection.endToStart,
              background: _dismissBg(),
              onDismissed: (_) => StorageService.toggleSave(chord.name),
              child: InkWell(
                onTap: () => _openDetail(context, chord),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chord.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
                            const SizedBox(height: 3),
                            Text(chord.inKey,
                                style: const TextStyle(fontSize: 13, color: _grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC), size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _savedProgressionsList() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: StorageService.savedProgressions,
      builder: (context, entries, _) {
        // Entries are 'progressionId|keyRoot'
        final items = <(ProgressionDef, String)>[];
        for (final e in entries) {
          final parts = e.split('|');
          if (parts.length != 2) continue;
          final def = findProgressionDef(parts[0]);
          if (def != null) items.add((def, parts[1]));
        }
        items.sort((a, b) => a.$1.name.compareTo(b.$1.name));

        if (items.isEmpty) {
          return _emptyState('Star a progression in a key to keep it here');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
          itemBuilder: (context, i) {
            final (def, keyRoot) = items[i];
            return Dismissible(
              key: Key('${def.id}|$keyRoot'),
              direction: DismissDirection.endToStart,
              background: _dismissBg(),
              onDismissed: (_) => StorageService.toggleSaveProgression(def.id, keyRoot),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProgressionDetailScreen(def: def, initialKey: keyRoot),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(def.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
                            const SizedBox(height: 3),
                            Text(
                              '${keyDisplayName(def, keyRoot)} · ${resolveProgression(def, keyRoot).take(6).join(' → ')}',
                              style: const TextStyle(fontSize: 13, color: _grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC), size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dismissBg() {
    return Container(
      color: const Color(0xFFFF5252),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_border_rounded, size: 56, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16, color: _grey)),
        ],
      ),
    );
  }
}

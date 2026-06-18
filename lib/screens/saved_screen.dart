import 'package:flutter/material.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/chord_service.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/screens/chord_detail_screen.dart';


class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _openDetail(BuildContext context, ChordMeta chord) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChordDetailScreen(chord: chord)));
    // no .then(_load) needed anymore — the notifier keeps everything in sync
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Saved Chords',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: StorageService.savedChords,
                builder: (context, names, _) {
                  final saved = getAllChords().where((c) => names.contains(c.name)).toList();
                  if (saved.isEmpty) return _emptyState();
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, i) {
                      final chord = saved[i];
                      return Dismissible(
                        key: Key(chord.name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: const Color(0xFFFF5252),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
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
                                      Text(chord.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                      const SizedBox(height: 3),
                                      Text(chord.inKey, style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border_rounded, size: 56, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text('Save chords to revisit them later', style: TextStyle(fontSize: 16, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}

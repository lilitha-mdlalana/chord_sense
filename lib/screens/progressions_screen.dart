import 'package:flutter/material.dart';
import 'package:chord_sense/models/chord_data.dart';
import 'package:chord_sense/services/progression_service.dart';
import 'package:chord_sense/screens/progression_detail_screen.dart';
import 'package:chord_sense/widgets/genre_tag.dart';

const _ink = Color(0xFF1A1A2E);
const _grey = Color(0xFF888888);

class ProgressionsScreen extends StatelessWidget {
  const ProgressionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<ProgressionDef>>{};
    for (final def in progressionCatalog) {
      sections.putIfAbsent(def.source, () => []).add(def);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 24, 0, 4),
              child: Text(
                'Progressions',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink),
              ),
            ),
            const Text(
              'Classic progressions in every key, with alternate voicings.',
              style: TextStyle(fontSize: 14, color: _grey),
            ),
            const SizedBox(height: 8),
            for (final entry in sections.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _grey,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              for (final def in entry.value) _ProgressionTile(def: def),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProgressionTile extends StatelessWidget {
  final ProgressionDef def;

  const _ProgressionTile({required this.def});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProgressionDetailScreen(def: def)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8E8E8)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      def.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _grey),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                def.description,
                style: const TextStyle(fontSize: 13, color: _grey, height: 1.3),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: def.styles.map((s) => GenreTag(label: s)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

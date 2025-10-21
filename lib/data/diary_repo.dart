import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum DiaryNoteType { text, audio, image }

class DiaryNote {
  final String id; // timestamp-based
  final DateTime date;
  final DiaryNoteType type;
  final String? text;
  final String? filePath; // for audio or image

  DiaryNote({
    required this.id,
    required this.date,
    required this.type,
    this.text,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
        'text': text,
        'filePath': filePath,
      };

  static DiaryNote fromJson(Map<String, dynamic> j) => DiaryNote(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: DiaryNoteType.values[(j['type'] as int)],
        text: j['text'] as String?,
        filePath: j['filePath'] as String?,
      );
}

const _kNotesKey = 'diary_notes_v1';

class DiaryRepo {
  DiaryRepo._();
  static final instance = DiaryRepo._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<DiaryNote>> listNotes() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kNotesKey);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(DiaryNote.fromJson)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> addNote(DiaryNote note) async {
    final prefs = await _prefs;
    final notes = await listNotes();
    notes.add(note);
    await prefs.setString(_kNotesKey, jsonEncode(notes.map((e) => e.toJson()).toList()));
  }

  static Future<String> nextId() async => DateTime.now().millisecondsSinceEpoch.toString();

  // Storing file paths returned by pickers/recorders; no app docs dir needed here.
}

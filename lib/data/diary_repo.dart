import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum DiaryNoteType { text, audio, image }

class DiaryNote {
  final String id; // timestamp-based
  final DateTime date;
  final DiaryNoteType type;
  final String? title;
  final String? text;
  final String? filePath; // for audio or image
  final String? emotionAsset; // optional: path to emotion icon

  DiaryNote({
    required this.id,
    required this.date,
    required this.type,
    this.title,
    this.text,
    this.filePath,
    this.emotionAsset,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
    'title': title,
        'text': text,
        'filePath': filePath,
    'emotionAsset': emotionAsset,
      };

  static DiaryNote fromJson(Map<String, dynamic> j) => DiaryNote(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        type: DiaryNoteType.values[(j['type'] as int)],
    title: j['title'] as String?,
        text: j['text'] as String?,
    filePath: j['filePath'] as String?,
    emotionAsset: j['emotionAsset'] as String?,
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

  Future<void> updateNote(DiaryNote note) async {
    final prefs = await _prefs;
    final notes = await listNotes();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
      await prefs.setString(_kNotesKey, jsonEncode(notes.map((e) => e.toJson()).toList()));
    }
  }

  Future<void> deleteNote(String id) async {
    final prefs = await _prefs;
    final notes = await listNotes();
    notes.removeWhere((n) => n.id == id);
    await prefs.setString(_kNotesKey, jsonEncode(notes.map((e) => e.toJson()).toList()));
  }

  static Future<String> nextId() async => DateTime.now().millisecondsSinceEpoch.toString();

  // Storing file paths returned by pickers/recorders; no app docs dir needed here.
}

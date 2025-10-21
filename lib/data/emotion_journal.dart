import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of emotions we track
enum EmotionType { happy, sad, angry, surprised, fear }

/// Storage keys
const _kJournalKey = 'emotion_journal_by_day'; // map: yyyy-MM-dd -> EmotionType.index

class EmotionJournal {
  EmotionJournal._();
  static final instance = EmotionJournal._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// Save an emotion for a given date (defaults to today)
  Future<void> saveEmotion(EmotionType type, {DateTime? date}) async {
    final prefs = await _prefs;
    final map = await _loadMap(prefs);
    final d = date ?? DateTime.now();
    final key = _fmt(d);
    map[key] = type.index;
    await prefs.setString(_kJournalKey, jsonEncode(map));
  }

  /// Load all stored emotions for the current month
  Future<Map<int, EmotionType>> loadMonth(DateTime month) async {
    final prefs = await _prefs;
    final map = await _loadMap(prefs);
    final result = <int, EmotionType>{};
    final days = DateTime(month.year, month.month + 1, 0).day;
    for (var day = 1; day <= days; day++) {
      final d = DateTime(month.year, month.month, day);
      final k = _fmt(d);
      final idx = map[k];
      if (idx is int && idx >= 0 && idx < EmotionType.values.length) {
        result[day] = EmotionType.values[idx];
      }
    }
    return result;
  }

  /// Compute counts for the given month
  Future<Map<EmotionType, int>> loadCounts(DateTime month) async {
    final daily = await loadMonth(month);
    final counts = {for (var t in EmotionType.values) t: 0};
    for (final t in daily.values) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts;
  }

  /// Get the most frequent emotion (returns null if tie with zero)
  Future<EmotionType?> mostFrequent(DateTime month) async {
    final counts = await loadCounts(month);
    EmotionType? best;
    var bestVal = 0;
    counts.forEach((t, v) {
      if (v > bestVal) {
        best = t;
        bestVal = v;
      }
    });
    return bestVal > 0 ? best : null;
  }

  Future<Map<String, dynamic>> _loadMap(SharedPreferences prefs) async {
    final raw = prefs.getString(_kJournalKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

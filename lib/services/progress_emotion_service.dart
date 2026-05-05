import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_1/data/emotion_journal.dart';
import 'package:flutter_application_1/services/diary_firestore_service.dart';

class MonthlyEmotionProgress {
  final Map<EmotionType, int> counts;
  final Map<int, Map<EmotionType, int>> daily;
  final EmotionType? mostFrequent;

  const MonthlyEmotionProgress({
    required this.counts,
    required this.daily,
    required this.mostFrequent,
  });
}

class ProgressEmotionService {
  ProgressEmotionService._();

  static final instance = ProgressEmotionService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<MonthlyEmotionProgress> loadForDate(DateTime date) async {
  final uid = _auth.currentUser?.uid;

  if (uid == null) {
    throw FirebaseAuthException(
      code: 'not-authenticated',
      message: 'Debes iniciar sesión.',
    );
  }

  return loadMonth(
    uid: uid,
    year: date.year,
    month: date.month,
  );
}

  Future<MonthlyEmotionProgress> loadCurrentMonth() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final now = DateTime.now();

    return loadMonth(
      uid: uid,
      year: now.year,
      month: now.month,
    );
  }

  Future<MonthlyEmotionProgress> loadMonth({
    required String uid,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final snap = await DiaryFirestoreService.instance
        .notesCol(uid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy('createdAt', descending: false)
        .get();

    final counts = <EmotionType, int>{
      for (final emotion in EmotionType.values) emotion: 0,
    };

    final daily = <int, Map<EmotionType, int>>{};

    for (final doc in snap.docs) {
      final data = doc.data();

      final emotionRaw = data['emocion'];

      if (emotionRaw == null) continue;

      final emotion = _parseEmotion(emotionRaw.toString());

      if (emotion == null) continue;

      final createdAt = data['createdAt'];

      if (createdAt is! Timestamp) continue;

      final date = createdAt.toDate();

      if (date.year != year || date.month != month) continue;

      final day = date.day;

      counts[emotion] = (counts[emotion] ?? 0) + 1;

      daily.putIfAbsent(day, () {
        return <EmotionType, int>{
          for (final emotion in EmotionType.values) emotion: 0,
        };
      });

      daily[day]![emotion] = (daily[day]![emotion] ?? 0) + 1;
    }

    EmotionType? mostFrequent;
    int maxCount = 0;

    counts.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = emotion;
      }
    });

    return MonthlyEmotionProgress(
      counts: counts,
      daily: daily,
      mostFrequent: maxCount == 0 ? null : mostFrequent,
    );
  }

  EmotionType? _parseEmotion(String value) {
    final clean = value.trim().toLowerCase();

    if (clean.contains('feliz') || clean.contains('felicidad')) {
      return EmotionType.happy;
    }

    if (clean.contains('triste') || clean.contains('tristeza')) {
      return EmotionType.sad;
    }

    if (clean.contains('enojo') ||
        clean.contains('enojado') ||
        clean.contains('enojada')) {
      return EmotionType.angry;
    }

    if (clean.contains('sorpresa') ||
        clean.contains('sorprendido') ||
        clean.contains('sorprendida')) {
      return EmotionType.surprised;
    }

    if (clean.contains('miedo') || clean.contains('temor')) {
      return EmotionType.fear;
    }

    return null;
  }
}
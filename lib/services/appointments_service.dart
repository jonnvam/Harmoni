import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentSlot {
  final DateTime inicio;
  final DateTime fin;
  final List<String> modalidades;

  const AppointmentSlot({
    required this.inicio,
    required this.fin,
    required this.modalidades,
  });
}

class AppointmentsService {
  AppointmentsService._();

  static final instance = AppointmentsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  static const Map<int, String> _weekdayToDiaId = {
    DateTime.monday: 'lunes',
    DateTime.tuesday: 'martes',
    DateTime.wednesday: 'miercoles',
    DateTime.thursday: 'jueves',
    DateTime.friday: 'viernes',
    DateTime.saturday: 'sabado',
    DateTime.sunday: 'domingo',
  };

  Future<List<AppointmentSlot>> loadAvailableSlots({
    required String psychologistUid,
    int daysAhead = 14,
  }) async {
    final psychologistDoc =
        await _db.collection('usuariosPsicologos').doc(psychologistUid).get();

    final psychologistData = psychologistDoc.data() ?? {};
    final sessionDuration =
        (psychologistData['sessionDurationMinutes'] is int)
            ? psychologistData['sessionDurationMinutes'] as int
            : 60;

    final availabilitySnap =
        await _db
            .collection('usuariosPsicologos')
            .doc(psychologistUid)
            .collection('disponibilidad')
            .get();

    final availabilityByDay = {
      for (final doc in availabilitySnap.docs) doc.id: doc.data(),
    };

    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(Duration(days: daysAhead + 1));

    /*
    final citasSnap = await _db
        .collection('citas')
        .where('psychologistUid', isEqualTo: psychologistUid)
        .where('fechaInicio', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('fechaInicio', isLessThan: Timestamp.fromDate(to))
        .get();

    final occupied = citasSnap.docs
        .map((doc) => doc.data())
        .where((data) {
          final estado = (data['estado'] ?? '').toString();
          return estado == 'solicitada' || estado == 'confirmada';
        })
        .map((data) {
          final start = data['fechaInicio'];
          final end = data['fechaFin'];

          if (start is! Timestamp || end is! Timestamp) return null;

          return (
            inicio: start.toDate(),
            fin: end.toDate(),
          );
        })
        .whereType<({DateTime inicio, DateTime fin})>()
        .toList();

**/

    final slots = <AppointmentSlot>[];

    for (int i = 0; i < daysAhead; i++) {
      final day = from.add(Duration(days: i));
      final diaId = _weekdayToDiaId[day.weekday];

      if (diaId == null) continue;

      final dayAvailability = availabilityByDay[diaId];

      if (dayAvailability == null) continue;
      if (dayAvailability['activo'] != true) continue;

      final bloques = dayAvailability['bloques'];
      final modalidadesRaw = dayAvailability['modalidades'];

      final modalidades =
          modalidadesRaw is List
              ? modalidadesRaw
                  .map((item) => item.toString())
                  .where((item) => item.isNotEmpty)
                  .toList()
              : <String>['online'];

      if (bloques is! List || bloques.isEmpty) continue;

      for (final rawBlock in bloques) {
        if (rawBlock is! Map) continue;

        final inicioText = (rawBlock['inicio'] ?? '').toString();
        final finText = (rawBlock['fin'] ?? '').toString();

        final blockStartMinutes = _timeToMinutes(inicioText);
        final blockEndMinutes = _timeToMinutes(finText);

        if (blockStartMinutes == null || blockEndMinutes == null) continue;

        var cursor = DateTime(
          day.year,
          day.month,
          day.day,
          blockStartMinutes ~/ 60,
          blockStartMinutes % 60,
        );

        final blockEnd = DateTime(
          day.year,
          day.month,
          day.day,
          blockEndMinutes ~/ 60,
          blockEndMinutes % 60,
        );

        while (cursor
                .add(Duration(minutes: sessionDuration))
                .isAfter(blockEnd) ==
            false) {
          final slotStart = cursor;
          final slotEnd = cursor.add(Duration(minutes: sessionDuration));

          final isPast = slotStart.isBefore(
            now.add(const Duration(minutes: 30)),
          );

          /*final overlaps = occupied.any(
            (item) => _overlaps(
              slotStart,
              slotEnd,
              item.inicio,
              item.fin,
            ),
          );
          */

          if (!isPast) {
            slots.add(
              AppointmentSlot(
                inicio: slotStart,
                fin: slotEnd,
                modalidades: modalidades,
              ),
            );
          }

          cursor = cursor.add(Duration(minutes: sessionDuration));
        }
      }
    }

    slots.sort((a, b) => a.inicio.compareTo(b.inicio));

    return slots;
  }

  Future<void> requestAppointment({
    required String psychologistUid,
    required String psychologistName,
    required AppointmentSlot slot,
    required String modalidad,
    required String motivoConsulta,
    required int precio,
    required String moneda,
    required String metodoPago,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (!slot.modalidades.contains(modalidad)) {
      throw ArgumentError('La modalidad seleccionada no está disponible.');
    }

    final user = _auth.currentUser;
    final appointmentId =
        '${psychologistUid}_${slot.inicio.millisecondsSinceEpoch}';

    await _db.collection('citas').doc(appointmentId).set({
      'patientUid': uid,
      'psychologistUid': psychologistUid,

      'patientName': user?.displayName ?? 'Paciente',
      'psychologistName': psychologistName,

      'fechaInicio': Timestamp.fromDate(slot.inicio),
      'fechaFin': Timestamp.fromDate(slot.fin),

      'modalidad': modalidad,
      'estado': 'solicitada',

      'motivoConsulta': motivoConsulta.trim(),
      'notasPaciente': null,
      'notasPsicologo': null,

      'precio': precio,
      'moneda': moneda,

      'metodoPago': metodoPago,
      'pagoEstado': 'pendiente',

      'meetUrl': null,
      'ubicacion': null,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'cancelledAt': null,
      'cancelReason': null,
    });
  }

  bool _overlaps(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }

  int? _timeToMinutes(String value) {
    final parts = value.split(':');

    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }
}

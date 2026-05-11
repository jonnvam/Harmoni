import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsychologistAppointmentModel {
  final String id;
  final String patientUid;
  final String psychologistUid;
  final String patientName;
  final String psychologistName;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String modalidad;
  final String estado;
  final String motivoConsulta;
  final int precio;
  final String moneda;
  final String metodoPago;
  final String pagoEstado;
  final String meetUrl;

  const PsychologistAppointmentModel({
    required this.id,
    required this.patientUid,
    required this.psychologistUid,
    required this.patientName,
    required this.psychologistName,
    required this.fechaInicio,
    required this.fechaFin,
    required this.modalidad,
    required this.estado,
    required this.motivoConsulta,
    required this.precio,
    required this.moneda,
    required this.metodoPago,
    required this.pagoEstado,
    required this.meetUrl,
  });

  factory PsychologistAppointmentModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final start = data['fechaInicio'];
    final end = data['fechaFin'];

    return PsychologistAppointmentModel(
      id: doc.id,
      patientUid: (data['patientUid'] ?? '').toString(),
      psychologistUid: (data['psychologistUid'] ?? '').toString(),
      patientName: (data['patientName'] ?? 'Paciente').toString(),
      psychologistName: (data['psychologistName'] ?? '').toString(),
      fechaInicio: start is Timestamp ? start.toDate() : DateTime.now(),
      fechaFin: end is Timestamp ? end.toDate() : DateTime.now(),
      modalidad: (data['modalidad'] ?? '').toString(),
      estado: (data['estado'] ?? 'solicitada').toString(),
      motivoConsulta: (data['motivoConsulta'] ?? '').toString(),
      precio: data['precio'] is int
          ? data['precio'] as int
          : data['precio'] is num
              ? (data['precio'] as num).toInt()
              : 0,
      moneda: (data['moneda'] ?? 'MXN').toString(),
      metodoPago: (data['metodoPago'] ?? 'pendiente').toString(),
      pagoEstado: (data['pagoEstado'] ?? 'pendiente').toString(),
      meetUrl: (data['meetUrl'] ?? '').toString(),
    );
  }
}

class PsychologistAppointmentsService {
  PsychologistAppointmentsService._();

  static final instance = PsychologistAppointmentsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<List<PsychologistAppointmentModel>> watchMyAppointments() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('citas')
        .where('psychologistUid', isEqualTo: uid)
        .orderBy('fechaInicio')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(PsychologistAppointmentModel.fromDoc).toList();
    });
  }

  Future<void> confirmAppointment({
    required PsychologistAppointmentModel appointment,
    String? meetUrl,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes confirmar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'solicitada') {
      throw ArgumentError('Solo puedes confirmar citas solicitadas.');
    }

    final cleanMeetUrl = meetUrl?.trim() ?? '';

    if (appointment.modalidad == 'online' && cleanMeetUrl.isEmpty) {
      throw ArgumentError(
        'Las citas en línea necesitan un enlace de videollamada.',
      );
    }

    final citaRef = _db.collection('citas').doc(appointment.id);

    final vinculoId =
        '${appointment.patientUid}_${appointment.psychologistUid}';

    final vinculoRef = _db
        .collection('vinculosPacientePsicologo')
        .doc(vinculoId);

    final batch = _db.batch();

    final citaUpdateData = <String, dynamic>{
      'estado': 'confirmada',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (appointment.modalidad == 'online') {
      citaUpdateData['meetUrl'] = cleanMeetUrl;
    }

    batch.update(citaRef, citaUpdateData);

    batch.set(
      vinculoRef,
      {
        'vinculoId': vinculoId,
        'patientUid': appointment.patientUid,
        'psychologistUid': appointment.psychologistUid,
        'patientName': appointment.patientName,
        'psychologistName': appointment.psychologistName,
        'status': 'activo',
        'origen': 'cita_confirmada',
        'primeraCitaId': appointment.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> rejectAppointment({
    required PsychologistAppointmentModel appointment,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes rechazar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'solicitada') {
      throw ArgumentError('Solo puedes rechazar citas solicitadas.');
    }

    await _db.collection('citas').doc(appointment.id).update({
      'estado': 'rechazada',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMeetUrl({
    required PsychologistAppointmentModel appointment,
    required String meetUrl,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes editar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'confirmada') {
      throw ArgumentError(
        'Solo puedes editar el enlace de una cita confirmada.',
      );
    }

    if (appointment.modalidad != 'online') {
      throw ArgumentError(
        'Solo las citas en línea pueden tener enlace de videollamada.',
      );
    }

    final cleanMeetUrl = meetUrl.trim();

    if (cleanMeetUrl.isEmpty) {
      throw ArgumentError('El enlace de la videollamada no puede estar vacío.');
    }

    await _db.collection('citas').doc(appointment.id).update({
      'meetUrl': cleanMeetUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeAppointment({
    required PsychologistAppointmentModel appointment,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes completar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'confirmada') {
      throw ArgumentError('Solo puedes completar citas confirmadas.');
    }

    await _db.collection('citas').doc(appointment.id).update({
      'estado': 'completada',
      'completedAt': FieldValue.serverTimestamp(),
      'completedBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markNoShow({
    required PsychologistAppointmentModel appointment,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes modificar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'confirmada') {
      throw ArgumentError(
        'Solo puedes marcar como no asistió una cita confirmada.',
      );
    }

    await _db.collection('citas').doc(appointment.id).update({
      'estado': 'no_asistio',
      'noShowAt': FieldValue.serverTimestamp(),
      'markedBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointment({
    required PsychologistAppointmentModel appointment,
    String? reason,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes cancelar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'confirmada') {
      throw ArgumentError('Solo puedes cancelar citas confirmadas.');
    }

    final cleanReason = reason?.trim();

    await _db.collection('citas').doc(appointment.id).update({
      'estado': 'cancelada_por_psicologo',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': uid,
      'cancelReason':
          cleanReason == null || cleanReason.isEmpty ? null : cleanReason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
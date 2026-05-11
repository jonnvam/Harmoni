import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssessmentConsentService {
  AssessmentConsentService._();

  static final instance = AssessmentConsentService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String buildConsentId({
    required String patientUid,
    required String psychologistUid,
    required String assessmentId,
  }) {
    return '${patientUid}_${psychologistUid}_$assessmentId';
  }

  Future<void> grantAssessmentConsent({
    required String assessmentId,
    required String psychologistUid,
    required String psychologistName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    final patientUid = user.uid;

    final consentId = buildConsentId(
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      assessmentId: assessmentId,
    );

    final consentRef = _db.collection('assessmentConsents').doc(consentId);

    final assessmentRef = _db
        .collection('usuariosPacientes')
        .doc(patientUid)
        .collection('assessments')
        .doc(assessmentId);

    final assessmentPath =
        'usuariosPacientes/$patientUid/assessments/$assessmentId';

    final batch = _db.batch();

    batch.set(consentRef, {
      'consentId': consentId,
      'patientUid': patientUid,
      'psychologistUid': psychologistUid,
      'psychologistName': psychologistName,
      'assessmentId': assessmentId,
      'assessmentPath': assessmentPath,
      'status': 'active',
      'allowedData': [
        'phq9',
        'gad7',
        'severity',
        'answers',
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'revokedAt': null,
    });

    batch.update(assessmentRef, {
      'consent': {
        'sharedWithPsychologist': true,
        'psychologistUid': psychologistUid,
        'psychologistName': psychologistName,
        'grantedAt': FieldValue.serverTimestamp(),
        'revokedAt': null,
        'consentId': consentId,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> revokeAssessmentConsent({
    required String assessmentId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    final patientUid = user.uid;

    final assessmentRef = _db
        .collection('usuariosPacientes')
        .doc(patientUid)
        .collection('assessments')
        .doc(assessmentId);

    final assessmentDoc = await assessmentRef.get();
    final assessmentData = assessmentDoc.data();

    if (assessmentData == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'assessment-not-found',
        message: 'No se encontró la evaluación.',
      );
    }

    final consent = assessmentData['consent'];

    if (consent is! Map || consent['consentId'] == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'consent-not-found',
        message: 'No se encontró un consentimiento activo.',
      );
    }

    final consentId = consent['consentId'].toString();
    final psychologistUid = (consent['psychologistUid'] ?? '').toString();
    final psychologistName = (consent['psychologistName'] ?? '').toString();
    final grantedAt = consent['grantedAt'];

    final consentRef = _db.collection('assessmentConsents').doc(consentId);

    final batch = _db.batch();

    batch.update(consentRef, {
      'status': 'revoked',
      'revokedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(assessmentRef, {
      'consent': {
        'sharedWithPsychologist': false,
        'psychologistUid': psychologistUid,
        'psychologistName': psychologistName,
        'grantedAt': grantedAt,
        'revokedAt': FieldValue.serverTimestamp(),
        'consentId': consentId,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
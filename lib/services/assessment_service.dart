import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';

class AssessmentService {
  AssessmentService._();

  static final instance = AssessmentService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String assessmentTypeInitial = 'initial_phq9_gad7';

  String severityPhq9(int score) {
    if (score <= 4) return 'minimal';
    if (score <= 9) return 'mild';
    if (score <= 14) return 'moderate';
    if (score <= 19) return 'moderately_severe';
    return 'severe';
  }

  String severityPhq9LabelEs(int score) {
    if (score <= 4) return 'Mínimo';
    if (score <= 9) return 'Leve';
    if (score <= 14) return 'Moderado';
    if (score <= 19) return 'Moderadamente severo';
    return 'Severo';
  }

  String severityGad7(int score) {
    if (score <= 4) return 'minimal';
    if (score <= 9) return 'mild';
    if (score <= 14) return 'moderate';
    return 'severe';
  }

  String severityGad7LabelEs(int score) {
    if (score <= 4) return 'Mínimo';
    if (score <= 9) return 'Leve';
    if (score <= 14) return 'Moderado';
    return 'Severo';
  }

  Future<bool> hasCompletedInitialAssessment(String uid) async {
    final profile = await UserProfileService.instance.loadProfileAfterAuth(uid);

    if (profile == null || !profile.isPaciente) {
      return false;
    }

    final doc = await _db
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid)
        .get();

    final data = doc.data();

    if (data == null) return false;

    final initialAssessment = data['initialAssessment'];

    if (initialAssessment is! Map) return false;

    return initialAssessment['completed'] == true;
  }

  Future<String> saveInitialAssessment({
    required String uid,
    required List<int> phqAnswers,
    required List<int> gadAnswers,
    required int phqScore,
    required int gadScore,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null || currentUser.uid != uid) {
      throw FirebaseAuthException(
        code: 'unauthorized',
        message: 'No tienes permiso para guardar esta evaluación.',
      );
    }

    if (phqAnswers.length != 9) {
      throw ArgumentError('PHQ-9 debe tener exactamente 9 respuestas.');
    }

    if (gadAnswers.length != 7) {
      throw ArgumentError('GAD-7 debe tener exactamente 7 respuestas.');
    }

    if (!_validAnswers(phqAnswers) || !_validAnswers(gadAnswers)) {
      throw ArgumentError('Las respuestas deben estar entre 0 y 3.');
    }

    final profile = await UserProfileService.instance.loadProfileAfterAuth(uid);

    if (profile == null || !profile.isPaciente) {
      throw FirebaseAuthException(
        code: 'invalid-profile',
        message: 'Solo los pacientes pueden guardar esta evaluación.',
      );
    }

    final patientRef = _db
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid);

    final patientDoc = await patientRef.get();

    if (!patientDoc.exists) {
      throw FirebaseAuthException(
        code: 'patient-profile-not-found',
        message: 'No se encontró el perfil del paciente.',
      );
    }

    final assessmentRef = patientRef.collection('assessments').doc();
    final assessmentId = assessmentRef.id;

    final batch = _db.batch();

    batch.set(assessmentRef, {
      'uid': uid,
      'type': assessmentTypeInitial,

      'phq9': {
        'answers': phqAnswers,
        'score': phqScore,
        'severity': severityPhq9(phqScore),
        'severityLabelEs': severityPhq9LabelEs(phqScore),
      },

      'gad7': {
        'answers': gadAnswers,
        'score': gadScore,
        'severity': severityGad7(gadScore),
        'severityLabelEs': severityGad7LabelEs(gadScore),
      },

      'consent': {
        'sharedWithPsychologist': false,
        'psychologistUid': null,
        'grantedAt': null,
        'revokedAt': null,
      },

      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // IMPORTANTE:
    // Actualizamos initialAssessment como mapa completo, no con rutas anidadas.
    // Esto hace que Firestore Rules detecte claramente los campos modificados.
    batch.update(patientRef, {
      'initialAssessment': {
        'completed': true,
        'latestAssessmentId': assessmentId,
        'completedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return assessmentId;
  }

  bool _validAnswers(List<int> answers) {
    return answers.every((answer) => answer >= 0 && answer <= 3);
  }
}